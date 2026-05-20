--機皇帝ワイゼル∞
-- 效果：
-- 这张卡不能通常召唤，用自身的效果才能特殊召唤。
-- ①：自己场上的表侧表示怪兽被效果破坏送去墓地时才能发动。手卡的这张卡特殊召唤。
-- ②：1回合1次，以对方场上1只同调怪兽为对象才能发动。那只对方同调怪兽给这张卡装备。
-- ③：这个攻击力上升自身的效果装备的怪兽的攻击力数值，其他的自己怪兽不能攻击宣言。
-- ④：1回合1次，对方把魔法卡发动时才能发动。那个发动无效并破坏。
function c68140974.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤，用自身的效果才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(0)
	c:RegisterEffect(e1)
	-- ①：自己场上的表侧表示怪兽被效果破坏送去墓地时才能发动。手卡的这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(68140974,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c68140974.spcon)
	e2:SetTarget(c68140974.sptg)
	e2:SetOperation(c68140974.spop)
	c:RegisterEffect(e2)
	-- 其他的自己怪兽不能攻击宣言。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(c68140974.antarget)
	c:RegisterEffect(e3)
	-- ②：1回合1次，以对方场上1只同调怪兽为对象才能发动。那只对方同调怪兽给这张卡装备。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(68140974,1))  --"装备同调怪兽"
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetTarget(c68140974.eqtg)
	e4:SetOperation(c68140974.eqop)
	c:RegisterEffect(e4)
	-- ④：1回合1次，对方把魔法卡发动时才能发动。那个发动无效并破坏。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(68140974,2))  --"魔法无效并破坏"
	e5:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_CHAINING)
	e5:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetCondition(c68140974.negcon)
	e5:SetTarget(c68140974.negtg)
	e5:SetOperation(c68140974.negop)
	c:RegisterEffect(e5)
end
-- 过滤送去墓地的卡：必须是原本由自己控制、且在场上表侧表示存在、因效果破坏而送去墓地的怪兽
function c68140974.filter(c,tp)
	return c:IsType(TYPE_MONSTER) and bit.band(c:GetReason(),0x41)==0x41 and c:IsPreviousControler(tp)
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
end
-- 特殊召唤效果的发动条件：检查送去墓地的卡中是否存在满足上述过滤条件的怪兽
function c68140974.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c68140974.filter,1,nil,tp)
end
-- 特殊召唤效果的靶向处理：检查自身是否能特殊召唤以及怪兽区域是否有空位，并设置特殊召唤的操作信息
function c68140974.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动准备阶段，检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,true,true) end
	-- 向系统宣告准备将自身特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的执行：将自身特殊召唤到场上，并完成正规召唤程序
function c68140974.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 尝试以无视召唤条件、表侧表示的方式将自身特殊召唤到自己场上，并判断是否成功
	if Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)~=0 then
		c:CompleteProcedure()
	end
end
-- 攻击限制效果的目标过滤：限制除自身以外的其他自己场上的怪兽
function c68140974.antarget(e,c)
	return c~=e:GetHandler()
end
-- 过滤可装备的怪兽：对方场上表侧表示存在且可以转移控制权的同调怪兽
function c68140974.eqfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and c:IsAbleToChangeControler()
end
-- 装备效果的靶向处理：检查魔法与陷阱区域是否有空位，并选择对方场上1只符合条件的同调怪兽作为对象
function c68140974.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c68140974.eqfilter(chkc) end
	-- 在效果发动准备阶段，检查自己场上是否有可用的魔法与陷阱区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 并检查对方场上是否存在可以作为效果对象的同调怪兽
		and Duel.IsExistingTarget(c68140974.eqfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家发送提示信息，要求选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家选择对方场上1只符合条件的同调怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c68140974.eqfilter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 装备限制条件：该装备卡只能装备给此卡（效果来源卡）
function c68140974.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 装备效果的执行：将对象怪兽作为装备卡装备给自身，并使其攻击力上升该怪兽的攻击力数值
function c68140974.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选为对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) then
		local atk=tc:GetTextAttack()
		if atk<0 then atk=0 end
		-- 尝试将对象怪兽作为装备卡装备给自身，若装备失败则结束处理
		if not Duel.Equip(tp,tc,c,false) then return end
		-- 那只对方同调怪兽给这张卡装备。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c68140974.eqlimit)
		tc:RegisterEffect(e1)
		if atk>0 then
			-- 这个攻击力上升自身的效果装备的怪兽的攻击力数值
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_EQUIP)
			e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_OWNER_RELATE)
			e2:SetCode(EFFECT_UPDATE_ATTACK)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			e2:SetValue(atk)
			tc:RegisterEffect(e2)
		end
	end
end
-- 无效效果的发动条件：自身未被战斗破坏，且对方发动了可以被无效的魔法卡的发动
function c68140974.negcon(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	-- 检查该连锁是否由对方发动、是否为魔法卡的发动、以及该发动是否可以被无效
	return ep~=tp and re:IsActiveType(TYPE_SPELL) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
end
-- 无效效果的靶向处理：向系统宣告准备无效该发动，若该卡可破坏则同时宣告准备破坏该卡
function c68140974.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向系统宣告准备无效该连锁发动的操作信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 向系统宣告准备破坏该卡的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 无效效果的执行：使该魔法卡的发动无效，并将其破坏
function c68140974.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 尝试无效该连锁的发动，并确认该卡在效果处理时仍与该效果相关联
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 因效果将该被无效发动的卡破坏并送去墓地
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
