--傀儡遊儀－サービスト・パペット
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以最多有自己场上的「机关傀儡」超量怪兽数量的对方场上的怪兽为对象才能发动。那些怪兽的控制权直到结束阶段得到。
-- ②：自己场上有「机关傀儡」超量怪兽存在的场合，把这个回合没有送去墓地的这张卡从墓地除外，以自己或对方的墓地1只超量怪兽为对象才能发动。那只怪兽在自己或对方的场上守备表示特殊召唤。
local s,id,o=GetID()
-- 注册两个效果：①改变对方场上怪兽控制权的效果和②从墓地特殊召唤超量怪兽的效果
function s.initial_effect(c)
	-- ①：以最多有自己场上的「机关傀儡」超量怪兽数量的对方场上的怪兽为对象才能发动。那些怪兽的控制权直到结束阶段得到。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"取得对方场上怪兽控制权"
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：自己场上有「机关傀儡」超量怪兽存在的场合，把这个回合没有送去墓地的这张卡从墓地除外，以自己或对方的墓地1只超量怪兽为对象才能发动。那只怪兽在自己或对方的场上守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"在自己或对方场上特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	-- 将此卡从墓地除外作为费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 过滤自己场上存在的「机关傀儡」超量怪兽
function s.filter(c)
	return c:IsSetCard(0x1083) and c:IsType(TYPE_XYZ) and c:IsFaceup()
end
-- 设定效果目标为对方场上的怪兽，最多为己方场上的「机关傀儡」超量怪兽数量
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 计算最多可选择的对方怪兽数量
	local ct=math.min(Duel.GetFieldGroup(tp,LOCATION_MZONE,0):FilterCount(s.filter,nil),Duel.GetLocationCount(tp,LOCATION_MZONE))
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and Card.IsControlerCanBeChanged(chkc) end
	-- 判断是否满足发动条件：存在可选择的对方怪兽且己方有足够怪兽区域
	if chk==0 then return Duel.IsExistingTarget(Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,nil) and ct>0 end
	-- 提示玩家选择要改变控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择满足条件的对方怪兽作为目标
	local g=Duel.SelectTarget(tp,Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,ct,nil)
	-- 设置连锁操作信息，表示将要改变控制权
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,g:GetCount(),0,0)
end
-- 处理效果：将目标怪兽的控制权交给玩家直到结束阶段
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选择的目标怪兽
	local tg=Duel.GetTargetsRelateToChain()
	-- 将目标怪兽的控制权交给玩家直到结束阶段
	Duel.GetControl(tg,tp,PHASE_END,1)
end
-- 过滤自己场上存在的「机关傀儡」超量怪兽
function s.cfilter(c)
	return c:IsSetCard(0x1083) and c:IsType(TYPE_XYZ) and c:IsFaceup()
end
-- 判定效果是否可以发动：己方场上有「机关傀儡」超量怪兽且此卡未在本回合送入墓地
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断己方场上有「机关傀儡」超量怪兽
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil) and
	-- 判断此卡未在本回合送入墓地
	Duel.GetTurnCount()~=e:GetHandler():GetTurnID() or e:GetHandler():IsReason(REASON_RETURN)
end
-- 过滤可特殊召唤的超量怪兽
function s.spfilter(c,e,tp)
	return c:IsType(TYPE_XYZ) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设定特殊召唤效果的目标为己方或对方墓地的超量怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.spfilter(chkc,e,tp) end
	-- 判断己方或对方场上有足够怪兽区域
	if chk==0 then return (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 or Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0)
		-- 判断己方或对方墓地存在可特殊召唤的超量怪兽
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的墓地超量怪兽作为目标
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp)
	-- 设置连锁操作信息，表示将要特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 处理效果：将目标怪兽特殊召唤到己方或对方场上
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 判断己方场上是否有足够怪兽区域进行特殊召唤
		local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
		-- 判断对方场上是否有足够怪兽区域进行特殊召唤
		local b2=Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE,1-tp)
		-- 让玩家选择将怪兽特殊召唤到己方或对方场上
		local op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,2)},  --"在自己场上特殊召唤"
			{b2,aux.Stringid(id,3)})  --"在对方场上特殊召唤"
		if op==1 then
			-- 将目标怪兽特殊召唤到己方场上
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		else
			-- 将目标怪兽特殊召唤到对方场上
			Duel.SpecialSummon(tc,0,tp,1-tp,false,false,POS_FACEUP_DEFENSE)
		end
	end
end
