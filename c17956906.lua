--終幕の光
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：支付1000的倍数的基本分，以支付的基本分每1000为1只的自己墓地的「女武神」怪兽为对象才能发动（同名卡最多1张）。那些怪兽特殊召唤。那之后，对方可以从自身墓地选最多有这个效果特殊召唤的怪兽数量的攻击力2000以下的怪兽特殊召唤。
function c17956906.initial_effect(c)
	-- 效果原文内容：这个卡名的卡在1回合只能发动1张。
	local e1 = Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,17956906+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c17956906.cost)
	e1:SetTarget(c17956906.target)
	e1:SetOperation(c17956906.operation)
	c:RegisterEffect(e1)
end
-- 检索满足条件的「女武神」怪兽，用于特殊召唤
function c17956906.spfilter(c,e,tp)
	return c:IsSetCard(0x122) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsCanBeEffectTarget(e)
end
-- 设置效果标签为100，表示可以发动
function c17956906.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		e:SetLabel(100)
		return true
	end
end
-- 效果原文内容：①：支付1000的倍数的基本分，以支付的基本分每1000为1只的自己墓地的「女武神」怪兽为对象才能发动（同名卡最多1张）。那些怪兽特殊召唤。那之后，对方可以从自身墓地选最多有这个效果特殊召唤的怪兽数量的攻击力2000以下的怪兽特殊召唤。
function c17956906.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取玩家墓地中的「女武神」怪兽组
	local g=Duel.GetMatchingGroup(c17956906.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	-- 获取玩家场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chkc then return false end
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 检查是否满足发动条件：场上存在可用区域、墓地有怪兽、玩家能支付1000基本分
		return ft>0 and g:GetCount()>0 and Duel.CheckLPCost(tp,1000,true)
	end
	e:SetLabel(0)
	local ct=math.min(g:GetClassCount(Card.GetCode),ft)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then
		ct=1
	end
	local pay_list = {}
	for p=1,ct do
		-- 构建可支付的基本分列表，用于选择特殊召唤的怪兽数量
		if Duel.CheckLPCost(tp,1000*p,true) then table.insert(pay_list,p) end
	end
	-- 提示玩家选择要特殊召唤的怪兽数量
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(17956906,0))  --"请选择要特殊召唤的怪兽数量"
	-- 玩家宣言要支付的基本分倍数
	local pay=Duel.AnnounceNumber(tp,table.unpack(pay_list))
	-- 支付宣言的基本分
	Duel.PayLPCost(tp,pay*1000,true)
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 设置额外检查条件为卡名不同
	aux.GCheckAdditional=aux.dncheck
	-- 从满足条件的怪兽组中选择指定数量的怪兽
	local sg=g:SelectSubGroup(tp,aux.TRUE,false,pay,pay)
	-- 取消额外检查条件
	aux.GCheckAdditional=nil
	-- 设置连锁目标为选中的怪兽组
	Duel.SetTargetCard(sg)
	-- 设置操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,sg,sg:GetCount(),0,0)
end
-- 检索满足条件的攻击力2000以下的怪兽，用于对方特殊召唤
function c17956906.spfilter2(c,e,tp)
	return c:IsAttackBelow(2000) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 处理效果的发动和特殊召唤流程
function c17956906.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 获取连锁中设置的目标怪兽组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if sg:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	if sg:GetCount()>ft then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		sg=sg:Select(tp,ft,ft,nil)
	end
	-- 将目标怪兽特殊召唤到场上
	local ct=Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	if ct<=0 then return end
	-- 获取对方墓地中的攻击力2000以下的怪兽组
	local g2=Duel.GetMatchingGroup(c17956906.spfilter2,tp,0,LOCATION_GRAVE,nil,e,1-tp)
	-- 计算对方最多可特殊召唤的怪兽数量
	local ct2=math.min(Duel.GetLocationCount(1-tp,LOCATION_MZONE),ct)
	if g2:GetCount()>0 and ct2>0
		-- 询问对方是否选择特殊召唤
		and Duel.SelectYesNo(1-tp,aux.Stringid(17956906,1)) then  --"是否特殊召唤？"
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if Duel.IsPlayerAffectedByEffect(1-tp,59822133) then ct2=1 end
		-- 中断当前效果，使之后的效果处理视为不同时处理
		Duel.BreakEffect()
		-- 提示对方玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		sg=g2:Select(1-tp,1,ct2,nil)
		-- 将对方墓地中的怪兽特殊召唤到对方场上
		Duel.SpecialSummon(sg,0,1-tp,1-tp,false,false,POS_FACEUP)
	end
end
