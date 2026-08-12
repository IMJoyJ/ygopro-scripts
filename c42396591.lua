--CNo.104 仮面魔踏士アンブラル・ヴィクトリー
-- 效果：
-- 5星怪兽×4
-- ①：自己·对方回合1次，把这张卡1个超量素材取除，以对方场上1张卡为对象才能发动。那张卡破坏。
-- ②：这张卡和对方怪兽进行战斗的伤害计算时发动。这张卡的攻击力·守备力只在那次伤害计算时变成那只对方怪兽的攻击力和守备力之内较高方的数值＋100。
-- ③：这张卡战斗破坏怪兽的场合发动。对方手卡随机1张送去墓地，对方基本分变成一半。
local s,id,o=GetID()
-- 初始化卡片：设定5星怪兽×4的超量召唤手续，并注册①破坏、②攻守变化、③送墓三个效果
function s.initial_effect(c)
	-- 添加超量召唤手续：以4只5星怪兽叠放进行超量召唤
	aux.AddXyzProcedure(c,nil,5,4)
	c:EnableReviveLimit()
	-- ①：自己·对方回合1次，把这张卡1个超量素材取除，以对方场上1张卡为对象才能发动。那张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.descost)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	-- ②：这张卡和对方怪兽进行战斗的伤害计算时发动。这张卡的攻击力·守备力只在那次伤害计算时变成那只对方怪兽的攻击力和守备力之内较高方的数值＋100。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"变化攻击力·守备力"
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e2:SetCondition(s.atkcon)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
	-- ③：这张卡战斗破坏怪兽的场合发动。对方手卡随机1张送去墓地，对方基本分变成一半。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"手卡送去墓地"
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetCondition(s.tgcon)
	e3:SetTarget(s.tgtg)
	e3:SetOperation(s.tgop)
	c:RegisterEffect(e3)
end
-- 将该卡登记为No.104号码卡，供混沌No.升阶等相关效果判定
aux.xyz_number[id]=104
-- 发动代价：把这张卡1个超量素材取除
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果目标处理：选择对方场上1张卡作为对象
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 检查对方场上是否存在可以成为这个效果对象的卡
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向发动玩家提示「请选择要破坏的卡」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 以对方场上1张卡为对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁的操作信息：确定要破坏的1张对象卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：若对象卡仍与连锁关联且在场上，则将其破坏
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁处理的对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsOnField() then
		-- 那张卡破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 发动条件：这张卡与表侧表示的对方怪兽进行战斗
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetBattleTarget()
	return tc and tc:IsFaceup() and tc:IsControler(1-tp)
end
-- 效果处理：取对方怪兽攻击力和守备力中较高方数值＋100，将这张卡的攻击力·守备力只在那次伤害计算时变成该数值
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetBattleTarget()
	if c and tc and c:IsFaceup() and tc:IsFaceup() then
		local val=math.max(tc:GetAttack(),tc:GetDefense())
		-- 这张卡的攻击力·守备力只在那次伤害计算时变成那只对方怪兽的攻击力和守备力之内较高方的数值＋100
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(val+100)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		c:RegisterEffect(e2)
	end
end
-- 发动条件：这张卡表侧表示且与那次战斗有关联（战斗破坏怪兽的场合）
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsFaceup() and e:GetHandler():IsRelateToBattle()
end
-- 目标处理：无需选卡，设置操作信息
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：预计将对方手卡1张送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,1-tp,LOCATION_HAND)
end
-- 效果处理：对方手卡随机1张送去墓地，成功的场合对方基本分变成一半
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得对方手卡
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if g:GetCount()==0 then return end
	local sg=g:RandomSelect(tp,1)
	-- 将随机选出的1张对方手卡送去墓地，并确认实际送墓成功
	if Duel.SendtoGrave(sg,REASON_EFFECT)~=0 and sg:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE) then
		-- 对方基本分变成一半（除以2向上取整）
		Duel.SetLP(1-tp,math.ceil(Duel.GetLP(1-tp)/2))
	end
end
