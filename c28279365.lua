--ブリンクアウト
-- 效果：
-- ①：以场上1只连接怪兽为对象才能发动。那只怪兽回到额外卡组。那之后，可以把已作为那只怪兽的连接素材送去自己墓地的1只怪兽特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果，设置为发动时点、取对象、自由连锁，目标为场上的连接怪兽，处理函数为s.target和s.activate
function s.initial_effect(c)
	-- 以场上1只连接怪兽为对象才能发动。那只怪兽回到额外卡组。那之后，可以把已作为那只怪兽的连接素材送去自己墓地的1只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOEXTRA+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：场上正面表示的连接怪兽且能回到额外卡组
function s.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_LINK) and c:IsAbleToExtra()
end
-- 效果处理函数，判断是否能选择目标，选择目标并设置操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) end
	-- 判断是否满足发动条件：场上存在满足条件的连接怪兽
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择满足条件的1只怪兽作为目标
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息，表示将目标怪兽送回额外卡组
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,g,1,0,0)
end
-- 过滤条件：墓地中的怪兽且是作为连接怪兽的连接素材被送去墓地，且能特殊召唤
function s.mgfilter(c,e,tp,link)
	return c:IsControler(tp) and c:IsLocation(LOCATION_GRAVE)
		and bit.band(c:GetReason(),0x10000008)==0x10000008 and c:GetReasonCard()==link
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动处理函数，将目标怪兽送回额外卡组，若成功则判断是否特殊召唤墓地中的怪兽
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) then return end
	local mg=tc:GetMaterial()
	local sumtype=tc:GetSummonType()
	-- 将目标怪兽送回额外卡组，若成功则继续处理
	if Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)~=0 then
		-- 过滤满足条件的墓地怪兽，排除受王家长眠之谷影响的怪兽
		mg=mg:Filter(aux.NecroValleyFilter(s.mgfilter),nil,e,tp,tc)
		if sumtype==SUMMON_TYPE_LINK and tc:IsLocation(LOCATION_EXTRA)
			-- 判断是否有足够的怪兽区域和可特殊召唤的怪兽数量
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and mg:GetCount()>0
			-- 询问玩家是否发动特殊召唤
			and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then  --"是否特殊召唤？"
			-- 提示玩家选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg=mg:Select(tp,1,1,nil)
			-- 中断当前效果，使后续处理视为不同时处理
			Duel.BreakEffect()
			-- 将选择的怪兽特殊召唤到场上
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
