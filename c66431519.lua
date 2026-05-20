--聖炎王 ガルドニクス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡·墓地存在，原本属性是炎属性的自己怪兽被战斗·效果破坏的场合才能发动。这张卡特殊召唤。
-- ②：这张卡召唤·特殊召唤的场合才能发动。「圣炎王 大鹏不死鸟」以外的自己的手卡·卡组·场上（表侧表示）1只兽族·兽战士族·鸟兽族的炎属性怪兽破坏。这张卡的攻击力直到回合结束时上升这个效果破坏的怪兽的攻击力一半数值。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含墓地状态检测、①效果（手卡·墓地被破坏特召）和②效果（召唤·特召成功时破坏手卡·卡组·场上怪兽并加攻）。
function s.initial_effect(c)
	-- 注册一个用于检测这张卡是否在怪兽被破坏前就已经存在于墓地的状态标记效果。
	local e0=aux.AddThisCardInGraveAlreadyCheck(c)
	-- ①：这张卡在手卡·墓地存在，原本属性是炎属性的自己怪兽被战斗·效果破坏的场合才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetLabelObject(e0)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤的场合才能发动。「圣炎王 大鹏不死鸟」以外的自己的手卡·卡组·场上（表侧表示）1只兽族·兽战士族·鸟兽族的炎属性怪兽破坏。这张卡的攻击力直到回合结束时上升这个效果破坏的怪兽的攻击力一半数值。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 过滤被破坏卡片的条件：原本属性为炎属性的自己怪兽，在怪兽区域被破坏或原本是怪兽卡被破坏，且不是因为当前效果自身导致。
function s.cfilter(c,tp,se)
	return c:IsPreviousControler(tp) and not c:IsPreviousLocation(LOCATION_SZONE)
		and (c:IsPreviousLocation(LOCATION_MZONE) or c:GetOriginalType()&TYPE_MONSTER~=0)
		and c:GetOriginalAttribute()==ATTRIBUTE_FIRE and c:IsReason(REASON_BATTLE+REASON_EFFECT)
		and (se==nil or c:GetReasonEffect()~=se)
end
-- 特殊召唤效果的发动条件：检查被破坏的卡中是否存在满足过滤条件的炎属性怪兽（若在墓地发动，需确保被破坏前已在墓地）。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local se=e:GetLabelObject():GetLabelObject()
	if c:IsLocation(LOCATION_HAND) then se=nil end
	return eg:IsExists(s.cfilter,1,c,tp,se)
end
-- 特殊召唤效果的发动准备（Target）：检查自身是否能特殊召唤以及怪兽区域是否有空位。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查发动时自己场上是否有可用的怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理的操作信息，表明此效果包含将自身特殊召唤的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 特殊召唤效果的执行函数：若此卡仍存在于原本位置，则将其特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡以表侧表示特殊召唤到发动效果玩家的场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤要破坏的卡片：除「圣炎王 大鹏不死鸟」以外的炎属性兽族·兽战士族·鸟兽族怪兽（手卡·卡组或场上表侧表示）。
function s.desfilter(c)
	return c:IsFaceupEx() and not c:IsCode(id)
		and c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST) and c:IsAttribute(ATTRIBUTE_FIRE)
end
-- 破坏并加攻效果的发动准备（Target）：检查手卡·卡组·场上是否存在可破坏的怪兽，并设置破坏的操作信息。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡、卡组、怪兽区域是否存在至少1只满足条件的炎属性怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理的操作信息，表明此效果包含破坏手卡、卡组或怪兽区域中1张卡的操作。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_DECK)
end
-- 破坏并加攻效果的执行函数：选择并破坏1只满足条件的怪兽，若破坏成功且自身在场上表侧表示，则自身攻击力上升被破坏怪兽攻击力一半的数值。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家发送提示信息，提示选择要破坏的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从手卡、卡组或怪兽区域中选择1只满足条件的炎属性怪兽。
	local g=Duel.SelectMatchingCard(tp,s.desfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 选中卡片时在场上显示被选为对象的动画效果（若选中的是场上的卡）。
		Duel.HintSelection(g)
		-- 尝试以效果破坏选中的怪兽，并判断是否成功破坏。
		if Duel.Destroy(g,REASON_EFFECT)>0 then
			local tc=g:GetFirst()
			local atk=tc:GetAttack()
			local c=e:GetHandler()
			if c:IsFaceup() and c:IsRelateToEffect(e) and atk>0 then
				-- 这张卡的攻击力直到回合结束时上升这个效果破坏的怪兽的攻击力一半数值。
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_UPDATE_ATTACK)
				e1:SetValue(atk//2)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
				c:RegisterEffect(e1)
			end
		end
	end
end
