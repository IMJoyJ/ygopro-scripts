--霊獣の騎襲
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己的墓地·除外状态的1只「灵兽使」怪兽和1只「精灵兽」怪兽为对象才能发动。那些怪兽守备表示特殊召唤。这张卡的发动后，直到回合结束时自己不是「灵兽」怪兽不能特殊召唤。
function c57815601.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以自己的墓地·除外状态的1只「灵兽使」怪兽和1只「精灵兽」怪兽为对象才能发动。那些怪兽守备表示特殊召唤。这张卡的发动后，直到回合结束时自己不是「灵兽」怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,57815601+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c57815601.target)
	e1:SetOperation(c57815601.activate)
	c:RegisterEffect(e1)
end
-- 过滤满足「灵兽使」系列、在墓地或除外区表侧表示且可守备表示特召，并存在对应可特召的「精灵兽」的怪兽
function c57815601.filter1(c,e,tp)
	return c:IsSetCard(0x10b5) and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
		-- 检测除当前卡外，是否存在满足过滤条件2（精灵兽）的怪兽
		and Duel.IsExistingTarget(c57815601.filter2,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,c,e,tp)
end
-- 过滤满足「精灵兽」系列、在墓地或除外区表侧表示且可守备表示特召的怪兽
function c57815601.filter2(c,e,tp)
	return c:IsSetCard(0x20b5) and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果发动时的对象选择与合法性检测
function c57815601.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检测自己场上的主要怪兽区域空位数是否大于1
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检测是否存在满足过滤条件1（灵兽使）的怪兽
		and Duel.IsExistingTarget(c57815601.filter1,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择1只满足条件的「灵兽使」怪兽作为效果的对象
	local g1=Duel.SelectTarget(tp,c57815601.filter1,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 排除已选怪兽，选择1只满足条件的「精灵兽」怪兽作为效果的对象
	local g2=Duel.SelectTarget(tp,c57815601.filter2,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,g1:GetFirst(),e,tp)
	g1:Merge(g2)
	-- 设置特殊召唤的操作信息，包含2只目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g1,2,0,0)
end
-- 效果处理的执行函数，包含特殊召唤和后续的特召限制
function c57815601.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上可用的主要怪兽区域空格数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 获取当前连锁中仍与此效果相关的对象怪兽
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if g:GetCount()==1 or not Duel.IsPlayerAffectedByEffect(tp,59822133) then
			if g:GetCount()<=ft then
				-- 将对象怪兽守备表示特殊召唤
				Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
			else
				-- 提示玩家选择要特殊召唤的怪兽
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
				local sg=g:Select(tp,ft,ft,nil)
				-- 将选择的、数量符合怪兽区域空格数的怪兽守备表示特殊召唤
				Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
				g:Sub(sg)
				-- 根据规则，将因格子不足而无法特殊召唤的其余对象怪兽送去墓地
				Duel.SendtoGrave(g,REASON_RULE)
			end
		end
	end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 这张卡的发动后，直到回合结束时自己不是「灵兽」怪兽不能特殊召唤。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetTarget(c57815601.splimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 为玩家注册直到回合结束生效的特殊召唤限制效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 限制不能特殊召唤「灵兽」以外的怪兽
function c57815601.splimit(e,c)
	return not c:IsSetCard(0xb5)
end
