--ロック・スケイル
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤成功的场合，以这张卡以外的场上1只表侧表示怪兽为对象才能发动。那只表侧表示怪兽当作装备卡使用给这张卡装备。
-- ②：种族·属性和这张卡的效果装备的怪兽卡相同的对方怪兽和这张卡进行战斗的伤害步骤开始时才能发动。那只对方怪兽破坏。
local s,id,o=GetID()
-- 注册卡片效果：①特殊召唤成功时将场上其他怪兽装备给自身；②与和装备怪兽相同种族·属性的对方怪兽战斗时将其破坏。
function s.initial_effect(c)
	-- ①：这张卡特殊召唤成功的场合，以这张卡以外的场上1只表侧表示怪兽为对象才能发动。那只表侧表示怪兽当作装备卡使用给这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target1)
	e1:SetOperation(s.activate1)
	c:RegisterEffect(e1)
	-- ②：种族·属性和这张卡的效果装备的怪兽卡相同的对方怪兽和这张卡进行战斗的伤害步骤开始时才能发动。那只对方怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_START)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.target2)
	e2:SetOperation(s.activate2)
	c:RegisterEffect(e2)
end
-- 过滤场上表侧表示且可以改变控制权的怪兽（若是己方怪兽则无需判定改变控制权）。
function s.filter1(c,tp)
	return c:IsFaceup() and (c:IsControler(tp) or c:IsAbleToChangeControler())
end
-- 效果①的发动准备与目标选择：检查魔陷区空位、是否存在合法的对象怪兽，并进行取对象操作。
function s.target1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter1(chkc,tp) and chkc~=c end
	-- 检查发动时己方魔陷区是否有可用的空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查场上是否存在除自身以外、满足过滤条件的表侧表示怪兽。
		and Duel.IsExistingTarget(s.filter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,c,tp) end
	-- 向玩家发送提示信息，要求选择要装备的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上1只满足条件的表侧表示怪兽作为效果的对象。
	local g=Duel.SelectTarget(tp,s.filter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,c,tp)
end
-- 效果①的处理：将选择的对象怪兽作为装备卡装备给这张卡，并添加装备限制和标记。
function s.activate1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果①选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	-- 检查对象怪兽是否仍适用此效果，且己方魔陷区仍有空位。
	if tc:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and s.filter1(tc,tp) and tc:IsType(TYPE_MONSTER) then
		-- 将对象怪兽作为装备卡装备给这张卡，若装备失败则结束处理。
		if not Duel.Equip(tp,tc,c,false) then return end
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,0)
		-- 当作装备卡使用给这张卡装备。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(s.eqlimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
-- 定义装备限制：该卡只能装备给此效果的发动者（即“岩鳞鱼”）。
function s.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 过滤由这张卡的效果所装备的、原本是怪兽卡的表侧表示装备卡。
function s.filter2(c)
	return c:IsFaceup() and c:GetOriginalType()&TYPE_MONSTER>0 and c:GetFlagEffect(id)>0
end
-- 效果②的发动准备：检查进行战斗的对方怪兽的种族·属性是否与因本卡效果装备的怪兽相同，并设置破坏的操作信息。
function s.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local tc=c:GetBattleTarget()
	if chk==0 then
		local ec=c:GetEquipGroup():Filter(s.filter2,nil):GetFirst()
		return ec and tc and tc:IsControler(1-tp) and tc:IsFaceup()
			and tc:IsAttribute(ec:GetOriginalAttribute()) and tc:IsRace(ec:GetOriginalRace())
	end
	-- 设置连锁处理的操作信息，表示将破坏1只进行战斗的对方怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
end
-- 效果②的处理：在伤害步骤开始时，将进行战斗的对方怪兽破坏。
function s.activate2(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetBattleTarget()
	if tc:IsRelateToBattle() and tc:IsControler(1-tp) then
		-- 因效果将该对方怪兽破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
