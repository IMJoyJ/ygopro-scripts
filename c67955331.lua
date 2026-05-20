--幸運の前借り
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己场上1只「占卜魔女」怪兽为对象才能发动。原本等级比那只怪兽低1星的1只魔法师族怪兽从手卡·卡组特殊召唤。这张卡的发动后，下次的自己回合中，自己不是魔法师族怪兽不能召唤·特殊召唤。
function c67955331.initial_effect(c)
	-- ①：以自己场上1只「占卜魔女」怪兽为对象才能发动。原本等级比那只怪兽低1星的1只魔法师族怪兽从手卡·卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,67955331+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c67955331.target)
	e1:SetOperation(c67955331.activate)
	c:RegisterEffect(e1)
end
-- 作为对象的「占卜魔女」怪兽的过滤条件函数
function c67955331.filter(c,e,tp)
	local lv=c:GetOriginalLevel()
	return lv>1 and c:IsFaceup() and c:IsSetCard(0x12e)
		-- 检查手卡·卡组是否存在原本等级比该怪兽低1星的、可特殊召唤的魔法师族怪兽
		and Duel.IsExistingMatchingCard(c67955331.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp,lv)
end
-- 要特殊召唤的魔法师族怪兽的过滤条件函数
function c67955331.spfilter(c,e,tp,clv)
	local lv=c:GetOriginalLevel()
	return lv>0 and lv==clv-1 and c:IsRace(RACE_SPELLCASTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动检测与对象选择函数
function c67955331.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c67955331.filter(chkc,e,tp) end
	-- 在chk==0（发动条件检测）时，检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己场上是否存在符合条件的「占卜魔女」怪兽
		and Duel.IsExistingTarget(c67955331.filter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只符合条件的「占卜魔女」怪兽作为对象
	Duel.SelectTarget(tp,c67955331.filter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置特殊召唤的操作信息（从手卡·卡组特殊召唤1只怪兽）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果①的执行函数
function c67955331.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup()
		-- 检查自己场上是否有可用的怪兽区域空格
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从手卡·卡组选择1只原本等级比对象怪兽低1星的魔法师族怪兽
		local g=Duel.SelectMatchingCard(tp,c67955331.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp,tc:GetOriginalLevel())
		if g:GetCount()>0 then
			-- 将选中的怪兽以表侧表示特殊召唤
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	-- 这张卡的发动后，下次的自己回合中，自己不是魔法师族怪兽不能召唤·特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	-- 将当前回合数保存为标签，以便后续判断是否为发动回合之后的自己回合
	e1:SetLabel(Duel.GetTurnCount())
	e1:SetCondition(c67955331.splimcon)
	e1:SetTarget(c67955331.splimit)
	-- 判断当前回合玩家是否为自己（用于计算限制效果的持续时间）
	if Duel.GetTurnPlayer()==tp then
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
	else
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,1)
	end
	-- 注册不能特殊召唤非魔法师族怪兽的玩家效果
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	-- 注册不能通常召唤非魔法师族怪兽的玩家效果
	Duel.RegisterEffect(e2,tp)
end
-- 限制效果的适用条件函数
function c67955331.splimcon(e)
	-- 过滤掉发动回合，并限制仅在自己的回合适用该效果
	return Duel.GetTurnCount()~=e:GetLabel() and Duel.GetTurnPlayer()==e:GetHandlerPlayer()
end
-- 限制召唤·特殊召唤的怪兽过滤函数
function c67955331.splimit(e,c)
	return not c:IsRace(RACE_SPELLCASTER)
end
