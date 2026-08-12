--CNo.105 BK 彗星のカエストス
-- 效果：
-- 5星怪兽×4
-- ①：这张卡战斗破坏怪兽送去墓地的场合发动。给与对方那只怪兽的原本攻击力一半数值的伤害。
-- ②：这张卡有「No.105 燃烧拳击手 流星之指套拳士」在作为超量素材的场合，得到以下效果。
-- ●1回合1次，把这张卡1个超量素材取除，以对方场上1只怪兽为对象才能发动。那只怪兽破坏，把表侧表示怪兽破坏的场合，给与对方那个攻击力数值的伤害。
function c85121942.initial_effect(c)
	-- 设置超量召唤手续：5星怪兽×4
	aux.AddXyzProcedure(c,nil,5,4)
	c:EnableReviveLimit()
	-- ①：这张卡战斗破坏怪兽送去墓地的场合发动。给与对方那只怪兽的原本攻击力一半数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(85121942,0))  --"伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetCondition(c85121942.damcon)
	e1:SetTarget(c85121942.damtg)
	e1:SetOperation(c85121942.damop)
	c:RegisterEffect(e1)
	-- ②：这张卡有「No.105 燃烧拳击手 流星之指套拳士」在作为超量素材的场合，得到以下效果。●1回合1次，把这张卡1个超量素材取除，以对方场上1只怪兽为对象才能发动。那只怪兽破坏，把表侧表示怪兽破坏的场合，给与对方那个攻击力数值的伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e2:SetDescription(aux.Stringid(85121942,1))  --"破坏并伤害"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c85121942.descon)
	e2:SetCost(c85121942.descost)
	e2:SetTarget(c85121942.destg)
	e2:SetOperation(c85121942.desop)
	c:RegisterEffect(e2)
end
-- 设置该怪兽的“No.”编号为105
aux.xyz_number[85121942]=105
-- 效果①的发动条件判定：自身在战斗中，且被破坏的怪兽是送去墓地的怪兽
function c85121942.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle() and bc:IsLocation(LOCATION_GRAVE) and bc:IsType(TYPE_MONSTER)
end
-- 效果①的发动准备：计算被破坏怪兽原本攻击力一半的数值，并设置伤害操作信息
function c85121942.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	local dam=math.floor(bc:GetTextAttack()/2)
	if dam<0 then dam=0 end
	-- 设置效果的对象玩家为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置效果的对象参数为计算出的伤害数值
	Duel.SetTargetParam(dam)
	-- 设置连锁的操作信息为给与对方玩家指定数值的伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 效果①的效果处理：获取目标玩家和伤害数值，给与对方伤害
function c85121942.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设置的对象玩家和对象参数（伤害数值）
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果伤害的方式给与目标玩家指定数值的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
-- 效果②的发动条件：这张卡有「No.105 燃烧拳击手 流星之指套拳士」在作为超量素材
function c85121942.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayGroup():IsExists(Card.IsCode,1,nil,59627393)
end
-- 效果②的发动代价：取除这张卡的1个超量素材
function c85121942.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果②的发动准备：选择对方场上1只怪兽作为对象，并设置破坏与伤害的操作信息
function c85121942.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 检查对方场上是否存在可以作为对象选择的怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1只怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁的操作信息为破坏选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置连锁的操作信息为给与对方玩家相当于该怪兽攻击力数值的伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,g:GetFirst():GetAttack())
end
-- 效果②的效果处理：破坏作为对象的怪兽，若成功破坏表侧表示怪兽，则给与对方其攻击力数值的伤害
function c85121942.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsControler(1-tp) then
		local atk=tc:GetAttack()
		if atk<0 or tc:IsFacedown() then atk=0 end
		-- 尝试用效果破坏该怪兽，并判断是否成功破坏
		if Duel.Destroy(tc,REASON_EFFECT)~=0 then
			-- 给与对方玩家相当于被破坏怪兽攻击力数值的效果伤害
			Duel.Damage(1-tp,atk,REASON_EFFECT)
		end
	end
end
