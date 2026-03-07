--究極・背水の陣
-- 效果：
-- 把基本分支付到变成100才能发动。自己墓地的名字带有「六武众」的怪兽尽可能特殊召唤。（同名卡最多1张。但是，场上存在的同名卡不能特殊召唤。）
function c32603633.initial_effect(c)
	-- 效果原文内容：把基本分支付到变成100才能发动。自己墓地的名字带有「六武众」的怪兽尽可能特殊召唤。（同名卡最多1张。但是，场上存在的同名卡不能特殊召唤。）
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c32603633.cost)
	e1:SetTarget(c32603633.tg)
	e1:SetOperation(c32603633.op)
	c:RegisterEffect(e1)
end
-- 效果作用：支付剩余LP至100点
function c32603633.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：获取玩家当前LP
	local lp=Duel.GetLP(tp)
	-- 效果作用：检查是否能支付LP
	if chk==0 then return Duel.CheckLPCost(tp,lp-100) end
	-- 效果作用：支付LP
	Duel.PayLPCost(tp,lp-100)
end
-- 效果原文内容：自己墓地的名字带有「六武众」的怪兽
function c32603633.filter(c,e,tp)
	return c:IsSetCard(0x103d) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 效果原文内容：场上存在的同名卡不能特殊召唤
		and not Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,c:GetCode())
end
-- 效果作用：判断是否满足特殊召唤条件
function c32603633.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：判断场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 效果作用：判断墓地是否有符合条件的卡
		and Duel.IsExistingMatchingCard(c32603633.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 效果作用：设置连锁操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 效果作用：处理特殊召唤流程
function c32603633.op(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取玩家场上可用区域数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 效果作用：获取满足条件的墓地怪兽组
	local g=Duel.GetMatchingGroup(c32603633.filter,tp,LOCATION_GRAVE,0,nil,e,tp)
	if g:GetCount()>0 then
		-- 效果作用：提示选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 效果作用：选择满足条件的卡组（卡名不重复）
		local sg=g:SelectSubGroup(tp,aux.dncheck,false,1,ft)
		-- 效果作用：将选中的卡特殊召唤到场上
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
