--迫りくる機械
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：把1只有「金属化·强化反射装甲」的卡名记述的怪兽或1张「金属化」陷阱卡从自己的卡组·墓地加入手卡。
-- ②：自己场上有「金属化」陷阱卡存在的场合，把墓地的这张卡除外，以对方场上1只守备表示怪兽为对象才能发动。那只怪兽变成表侧攻击表示。
local s,id,o=GetID()
-- 初始化效果注册函数，包含①效果（检索/回收）和②效果（墓地除外转表侧攻击）的注册
function s.initial_effect(c)
	-- 注册该卡关联的卡片密码「金属化·强化反射装甲」
	aux.AddCodeList(c,89812483)
	-- ①：把1只有「金属化·强化反射装甲」的卡名记述的怪兽或1张「金属化」陷阱卡从自己的卡组·墓地加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"加入手卡"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：自己场上有「金属化」陷阱卡存在的场合，把墓地的这张卡除外，以对方场上1只守备表示怪兽为对象才能发动。那只怪兽变成表侧攻击表示。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"改变表示形式"
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.poscon)
	-- 设置发动成本为把墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.postg)
	e2:SetOperation(s.posop)
	c:RegisterEffect(e2)
end
-- 过滤条件：属于「金属化」系列的陷阱卡，或者卡名记述了「金属化·强化反射装甲」的怪兽，且能加入手卡
function s.filter(c)
	-- 检查卡片是否为「金属化」陷阱卡或记述了「金属化·强化反射装甲」的怪兽，并且可以加入手卡
	return (c:IsSetCard(0x1ba) and c:IsType(TYPE_TRAP) or aux.IsCodeListed(c,89812483) and c:IsType(TYPE_MONSTER)) and c:IsAbleToHand()
end
-- ①效果的发动准备与合法性检测函数
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组或墓地是否存在至少1张满足过滤条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置操作信息为从卡组或墓地将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- ①效果的实际处理函数
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组或墓地选择1张满足条件的卡（受王家之谷影响）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤条件：自己场上表侧表示的「金属化」陷阱卡
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1ba) and c:IsType(TYPE_TRAP)
end
-- ②效果的发动条件判定函数
function s.poscon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的「金属化」陷阱卡
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 过滤条件：守备表示且可以改变表示形式的怪兽
function s.posfilter(c)
	return c:IsPosition(POS_DEFENSE) and c:IsCanChangePosition()
end
-- ②效果的发动准备与取对象处理函数
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsPosition(POS_DEFENSE) end
	-- 检查对方场上是否存在可以改变表示形式的守备表示怪兽
	if chk==0 then return Duel.IsExistingTarget(s.posfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向对方玩家提示本效果的发动
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 提示玩家选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 选择对方场上1只守备表示怪兽作为效果对象
	local g=Duel.SelectTarget(tp,s.posfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息为改变1只怪兽的表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- ②效果的实际处理函数
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) then
		-- 将目标怪兽变成表侧攻击表示
		Duel.ChangePosition(tc,POS_FACEUP_ATTACK)
	end
end
