--魔頭砲グレンザウルス
-- 效果：
-- 4星怪兽×2
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己的恐龙族怪兽战斗破坏对方怪兽送去墓地时，把这张卡1个超量素材取除才能发动。给与对方1000伤害。那之后，这张卡的攻击力上升1000。
-- ②：超量召唤的这张卡被破坏的场合，以场上1张卡为对象才能发动。那张卡破坏，给与对方1000伤害。
local s,id,o=GetID()
-- 初始化效果，启用复活限制并添加XYZ召唤手续，注册两个诱发效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加XYZ召唤手续，使用4星怪兽叠放2只以上进行XYZ召唤
	aux.AddXyzProcedure(c,nil,4,2)
	-- ①：自己的恐龙族怪兽战斗破坏对方怪兽送去墓地时，把这张卡1个超量素材取除才能发动。给与对方1000伤害。那之后，这张卡的攻击力上升1000。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DAMAGE+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.damcon)
	e1:SetCost(s.damcost)
	e1:SetTarget(s.damtg)
	e1:SetOperation(s.damop)
	c:RegisterEffect(e1)
	-- ②：超量召唤的这张卡被破坏的场合，以场上1张卡为对象才能发动。那张卡破坏，给与对方1000伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.descon)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
-- 过滤器函数，判断被战斗破坏的怪兽是否为己方恐龙族怪兽且在墓地
function s.egfilter(c,tp)
	if not c:IsPreviousControler(1-tp) or not c:IsLocation(LOCATION_GRAVE) then return false end
	local bc=c:GetReasonCard()
	if not bc then return false end
	if bc:IsRelateToBattle() then
		return bc:IsFaceup() and bc:IsLocation(LOCATION_MZONE) and bc:IsControler(tp) and bc:IsType(TYPE_MONSTER) and bc:IsRace(RACE_DINOSAUR)
	else
		return bc:GetPreviousPosition()&POS_FACEUP>0 and bc:GetPreviousLocation()&LOCATION_MZONE==LOCATION_MZONE and bc:IsPreviousControler(tp)
			and bc:GetPreviousTypeOnField()&TYPE_MONSTER==TYPE_MONSTER and c:GetPreviousRaceOnField()&RACE_DINOSAUR==RACE_DINOSAUR
	end
end
-- 判断是否有满足条件的被战斗破坏的怪兽
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.egfilter,1,nil,tp)
end
-- 支付1个超量素材作为代价
function s.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_COST) end
	c:RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 设置伤害目标和参数
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁对象玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置连锁对象参数为1000
	Duel.SetTargetParam(1000)
	-- 设置操作信息为对对方造成1000伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
-- 处理①效果的发动，造成伤害并提升攻击力
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中的目标玩家和参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对对方造成1000伤害
	if Duel.Damage(p,d,REASON_EFFECT)>0 then
		local c=e:GetHandler()
		if c:IsRelateToEffect(e) and c:IsFaceup() then
			-- 中断当前效果，使后续效果视为错时处理
			Duel.BreakEffect()
			-- 提升自身攻击力1000
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(1000)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
			c:RegisterEffect(e1)
		end
	end
end
-- 判断该卡是否为XYZ召唤且从主要怪兽区被破坏
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetPreviousLocation()&LOCATION_MZONE==LOCATION_MZONE and c:IsSummonType(SUMMON_TYPE_XYZ)
end
-- 设置②效果的目标选择和操作信息
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 判断是否存在可选择的目标卡
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张卡作为破坏对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息为破坏选中的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
	-- 设置操作信息为对对方造成1000伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
-- 处理②效果的发动，破坏目标卡并造成伤害
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	-- 判断目标卡是否存在且被破坏成功
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)>0 then
		-- 对对方造成1000伤害
		Duel.Damage(1-tp,1000,REASON_EFFECT)
	end
end
