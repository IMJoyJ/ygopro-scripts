--妖仙獣 左鎌神柱
-- 效果：
-- ←3 【灵摆】 3→
-- ①：自己场上的「妖仙兽」怪兽被战斗·效果破坏的场合，可以作为代替把这张卡破坏。
-- 【怪兽效果】
-- ①：这张卡召唤成功的场合发动。这张卡变成守备表示。
-- ②：只要这张卡在怪兽区域存在，对方不能把这张卡以外的自己场上的「妖仙兽」怪兽作为效果的对象。
function c65025250.initial_effect(c)
	-- 为卡片注册灵摆怪兽属性（包括灵摆召唤和灵摆卡的发动）
	aux.EnablePendulumAttribute(c)
	-- ①：自己场上的「妖仙兽」怪兽被战斗·效果破坏的场合，可以作为代替把这张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_PZONE)
	e2:SetTarget(c65025250.reptg)
	e2:SetValue(c65025250.repval)
	e2:SetOperation(c65025250.repop)
	c:RegisterEffect(e2)
	-- ①：这张卡召唤成功的场合发动。这张卡变成守备表示。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(65025250,0))  --"变成守备表示"
	e3:SetCategory(CATEGORY_POSITION)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetTarget(c65025250.postg)
	e3:SetOperation(c65025250.posop)
	c:RegisterEffect(e3)
	-- ②：只要这张卡在怪兽区域存在，对方不能把这张卡以外的自己场上的「妖仙兽」怪兽作为效果的对象。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetTarget(c65025250.tgtg)
	-- 设置不能成为对方卡片效果的对象
	e4:SetValue(aux.tgoval)
	c:RegisterEffect(e4)
end
-- 过滤自己场上表侧表示、非代替破坏状态的「妖仙兽」怪兽
function c65025250.filter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)
		and c:IsSetCard(0xb3) and not c:IsReason(REASON_REPLACE)
end
-- 代替破坏效果的条件判断，检查是否有符合条件的「妖仙兽」怪兽将被破坏，且自身可以被破坏
function c65025250.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return eg:IsExists(c65025250.filter,1,nil,tp)
		and c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED) end
	-- 询问玩家是否使用代替破坏效果
	return Duel.SelectEffectYesNo(tp,c,96)
end
-- 确定代替破坏效果所适用的受保护卡片过滤条件
function c65025250.repval(e,c)
	return c65025250.filter(c,e:GetHandlerPlayer())
end
-- 代替破坏效果的执行函数，将自身破坏
function c65025250.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 作为代替，将这张卡因效果而破坏
	Duel.Destroy(e:GetHandler(),REASON_EFFECT+REASON_REPLACE)
end
-- 召唤成功时改变表示形式效果的启动条件与操作信息设置
function c65025250.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAttackPos() end
	-- 设置操作信息，表明此效果将改变自身表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,e:GetHandler(),1,0,0)
end
-- 召唤成功时改变表示形式效果的执行函数，将自身变为守备表示
function c65025250.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsPosition(POS_FACEUP_ATTACK) and c:IsRelateToEffect(e) then
		-- 将这张卡变为表侧守备表示
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	end
end
-- 过滤不能成为对象的目标，即这张卡以外的自己场上的「妖仙兽」怪兽
function c65025250.tgtg(e,c)
	return c~=e:GetHandler() and c:IsSetCard(0xb3)
end
