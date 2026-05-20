--海晶乙女環流
-- 效果：
-- 自己场上有连接3以上的「海晶少女」怪兽存在的场合，这张卡的发动从手卡也能用。
-- ①：以自己场上1只水属性连接怪兽为对象才能发动。那只怪兽回到持有者的额外卡组，和那只怪兽是卡名不同并是连接标记数量相同的1只「海晶少女」连接怪兽当作连接召唤从额外卡组特殊召唤。这个回合，这个效果特殊召唤的怪兽不能直接攻击，不会被战斗破坏。
function c83723605.initial_effect(c)
	-- ①：以自己场上1只水属性连接怪兽为对象才能发动。那只怪兽回到持有者的额外卡组，和那只怪兽是卡名不同并是连接标记数量相同的1只「海晶少女」连接怪兽当作连接召唤从额外卡组特殊召唤。这个回合，这个效果特殊召唤的怪兽不能直接攻击，不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOEXTRA+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetTarget(c83723605.target)
	e1:SetOperation(c83723605.activate)
	c:RegisterEffect(e1)
	-- 自己场上有连接3以上的「海晶少女」怪兽存在的场合，这张卡的发动从手卡也能用。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(83723605,0))  --"适用「海晶少女环流」的效果来发动"
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(c83723605.handcon)
	c:RegisterEffect(e2)
end
-- 过滤自己场上表侧表示、可以回到额外卡组的水属性连接怪兽，且额外卡组存在可特殊召唤的卡名不同、连接标记相同的「海晶少女」连接怪兽
function c83723605.texfilter(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_LINK) and c:IsAttribute(ATTRIBUTE_WATER) and c:IsAbleToExtra()
		-- 检查额外卡组是否存在满足特殊召唤条件的「海晶少女」连接怪兽
		and Duel.IsExistingMatchingCard(c83723605.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
end
-- 过滤额外卡组中与目标怪兽卡名不同、连接标记相同，且可以当作连接召唤特殊召唤的「海晶少女」连接怪兽
function c83723605.spfilter(c,e,tp,rc)
	return c:IsSetCard(0x12b) and c:IsType(TYPE_LINK) and c:IsLink(rc:GetLink()) and not c:IsCode(rc:GetCode())
		-- 检查该卡是否可以当作连接召唤特殊召唤，且在目标怪兽离场后额外怪兽区域有足够的空位
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_LINK,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,rc,c)>0
end
-- 效果①的发动准备与对象选择
function c83723605.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c83723605.texfilter(chkc,e,tp) end
	-- 检查是否存在必须作为连接素材的限制
	if chk==0 then return aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_LMATERIAL)
		-- 检查自己场上是否存在可以作为对象的水属性连接怪兽
		and Duel.IsExistingTarget(c83723605.texfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示玩家选择要返回额外卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择自己场上1只水属性连接怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c83723605.texfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置操作信息，表示此效果包含将选中的怪兽送回额外卡组的处理
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,g,1,0,0)
	-- 设置操作信息，表示此效果包含从额外卡组特殊召唤怪兽的处理
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果①的效果处理（回到额外卡组并特殊召唤）
function c83723605.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 将对象怪兽送回额外卡组，并确认其已成功回到额外卡组
	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,0,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_EXTRA)
		-- 再次检查连接素材限制
		and aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_LMATERIAL) then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从额外卡组选择1只满足条件的「海晶少女」连接怪兽
		local g=Duel.SelectMatchingCard(tp,c83723605.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc)
		local sc=g:GetFirst()
		if sc then
			sc:SetMaterial(nil)
			-- 将选择的怪兽当作连接召唤特殊召唤到场上
			if Duel.SpecialSummon(sc,SUMMON_TYPE_LINK,tp,tp,false,false,POS_FACEUP)~=0 then
				-- 不会被战斗破坏
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
				e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
				e1:SetRange(LOCATION_MZONE)
				e1:SetValue(1)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				sc:RegisterEffect(e1,true)
				-- 这个回合，这个效果特殊召唤的怪兽不能直接攻击，自己场上有连接3以上的「海晶少女」怪兽存在的场合，这张卡的发动从手卡也能用。
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
				e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				sc:RegisterEffect(e2,true)
				sc:CompleteProcedure()
			end
		end
	end
end
-- 过滤自己场上表侧表示的连接3以上的「海晶少女」怪兽
function c83723605.hcfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x12b) and c:IsLinkAbove(3)
end
-- 手卡发动条件判断
function c83723605.handcon(e)
	-- 检查自己场上是否存在连接3以上的「海晶少女」怪兽
	return Duel.IsExistingMatchingCard(c83723605.hcfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
