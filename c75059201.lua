--F.A.ターボチャージャー
-- 效果：
-- ①：这张卡的攻击力上升这张卡的等级×300，原本的等级或者阶级比这张卡的等级低的对方怪兽只能以这张卡作为攻击对象，只能以这张卡作为效果的对象。
-- ②：「方程式运动员」魔法·陷阱卡的效果发动的场合才能发动（伤害步骤也能发动）。这张卡的等级上升1星。
-- ③：这张卡的等级是7星以上，自己的「方程式运动员」怪兽进行战斗的场合，直到伤害步骤结束时对方不能把怪兽的效果发动。
function c75059201.initial_effect(c)
	-- ①：这张卡的攻击力上升这张卡的等级×300
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c75059201.atkval)
	c:RegisterEffect(e1)
	-- 原本的等级或者阶级比这张卡的等级低的对方怪兽只能以这张卡作为攻击对象
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetTarget(c75059201.atglimit)
	e2:SetValue(c75059201.atlimit)
	c:RegisterEffect(e2)
	-- 原本的等级或者阶级比这张卡的等级低的对方怪兽...只能以这张卡作为效果的对象。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0xff,0xff)
	e3:SetTarget(c75059201.tglimit)
	e3:SetValue(c75059201.tgval)
	c:RegisterEffect(e3)
	-- ②：「方程式运动员」魔法·陷阱卡的效果发动的场合才能发动（伤害步骤也能发动）。这张卡的等级上升1星。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(75059201,0))
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e4:SetCondition(c75059201.lvcon)
	e4:SetOperation(c75059201.lvop)
	c:RegisterEffect(e4)
	-- ③：这张卡的等级是7星以上，自己的「方程式运动员」怪兽进行战斗的场合，直到伤害步骤结束时对方不能把怪兽的效果发动。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetCode(EFFECT_CANNOT_ACTIVATE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTargetRange(0,1)
	e5:SetValue(c75059201.aclimit)
	e5:SetCondition(c75059201.actcon)
	c:RegisterEffect(e5)
end
-- 计算攻击力上升值（自身等级×300）
function c75059201.atkval(e,c)
	return c:GetLevel()*300
end
-- 过滤原本等级或阶级比此卡等级低的怪兽
function c75059201.atglimit(e,c)
	local lv=e:GetHandler():GetLevel()
	if c:GetRank()>0 then
		return c:GetOriginalRank()<lv
	elseif c:GetLevel()>0 then
		return c:GetOriginalLevel()<lv
	else return false end
end
-- 限制攻击目标不能是此卡以外的怪兽
function c75059201.atlimit(e,c)
	return c~=e:GetHandler()
end
-- 限制效果对象不能是此卡以外的卡
function c75059201.tglimit(e,c)
	return c~=e:GetHandler()
end
-- 过滤由原本等级或阶级比此卡等级低的对方怪兽发动的、以其他卡为对象的效果
function c75059201.tgval(e,re,rp)
	-- 判断是否为对方玩家发动的以己方卡片为对象的效果
	if not aux.tgoval(e,re,rp) then return false end
	local c=re:GetHandler()
	local lv=e:GetHandler():GetLevel()
	if c:GetRank()>0 then
		return c:GetOriginalRank()<lv
	elseif c:GetLevel()>0 then
		return c:GetOriginalLevel()<lv
	else return false end
end
-- 判断是否是「方程式运动员」魔法·陷阱卡的效果发动
function c75059201.lvcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and re:GetHandler():IsSetCard(0x107)
end
-- 使这张卡的等级上升1星
function c75059201.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 这张卡的等级上升1星。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- 限制对方不能发动怪兽的效果
function c75059201.aclimit(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER)
end
-- 判断此卡等级是否在7星以上，且是否有自己的「方程式运动员」怪兽进行战斗
function c75059201.actcon(e)
	if not e:GetHandler():IsLevelAbove(7) then return false end
	-- 获取当前攻击宣言的怪兽
	local a=Duel.GetAttacker()
	if not a then return false end
	local d=a:GetBattleTarget()
	if a:IsControler(1-e:GetHandler():GetControler()) then a,d=d,a end
	return a and a:IsSetCard(0x107)
end
