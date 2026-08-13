--機皇帝スキエル∞
-- 效果：
-- 这张卡不能通常召唤，用自身的效果才能特殊召唤。
-- ①：自己场上的表侧表示怪兽被效果破坏送去墓地时才能发动。手卡的这张卡特殊召唤。
-- ②：1回合1次，以对方场上1只同调怪兽为对象才能发动。那只对方同调怪兽给这张卡装备。
-- ③：这个攻击力上升自身的效果装备的怪兽的攻击力数值，其他的自己怪兽不能攻击宣言。
-- ④：把给自身装备的1只自己怪兽送去墓地才能发动。这个回合这张卡可以直接攻击。
function c31930787.initial_effect(c)
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
	e2:SetDescription(aux.Stringid(31930787,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c31930787.spcon)
	e2:SetTarget(c31930787.sptg)
	e2:SetOperation(c31930787.spop)
	c:RegisterEffect(e2)
	-- 其他的自己怪兽不能攻击宣言。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(c31930787.antarget)
	c:RegisterEffect(e3)
	-- ②：1回合1次，以对方场上1只同调怪兽为对象才能发动。那只对方同调怪兽给这张卡装备。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(31930787,1))  --"装备同调怪兽"
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetTarget(c31930787.eqtg)
	e4:SetOperation(c31930787.eqop)
	c:RegisterEffect(e4)
	-- ④：把给自身装备的1只自己怪兽送去墓地才能发动。这个回合这张卡可以直接攻击。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(31930787,2))  --"直接攻击"
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCondition(c31930787.dircon)
	e5:SetCost(c31930787.dircost)
	e5:SetOperation(c31930787.dirop)
	c:RegisterEffect(e5)
end
-- 过滤函数：判断送去墓地的卡是否为原本控制者为自己的表侧表示怪兽，且是被效果破坏从怪兽区送去墓地，用于触发①的特殊召唤条件。
function c31930787.filter(c,tp)
	return c:IsType(TYPE_MONSTER) and bit.band(c:GetReason(),0x41)==0x41 and c:IsPreviousControler(tp)
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
end
-- 触发条件：本组送入墓地的卡中存在至少1张满足filter的卡，即自己场上有表侧表示怪兽被效果破坏送去墓地。
function c31930787.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c31930787.filter,1,nil,tp)
end
-- 发动目标的合法性检查：自己的主要怪兽区有空位，且手牌的这张卡满足特殊召唤条件（无视召唤条件和苏生限制）。
function c31930787.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的主要怪兽区是否有可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,true,true) end
	-- 设置本次连锁的特殊召唤操作信息，对象为手牌这张卡，数量1，方便后续效果联动检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤处理：若这张卡仍与效果关联，则将其表侧表示特殊召唤到自己场上；召唤成功则调用CompleteProcedure完成特殊召唤手续。
function c31930787.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 调用SpecialSummon尝试特殊召唤，返回值非0表示特殊召唤成功。
	if Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)~=0 then
		c:CompleteProcedure()
	end
end
-- 不能攻击宣言的过滤：除这张卡自身以外的自己场上怪兽都不能攻击宣言。
function c31930787.antarget(e,c)
	return c~=e:GetHandler()
end
-- 装备对象过滤：选择对方场上表侧表示的同调怪兽，且该怪兽能够变更控制权（即可被装备）。
function c31930787.eqfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and c:IsAbleToChangeControler()
end
-- ②的发动目标设置：若检查指定目标则验证其在对方怪兽区且满足过滤条件；若为发动判定则检查自己有魔陷区空位且存在合法对象。
function c31930787.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c31930787.eqfilter(chkc) end
	-- 检查自己的魔陷区是否有可用的空格（装备同调怪兽需要占用魔陷区）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查对方怪兽区是否存在至少1只满足过滤条件的同调怪兽作为装备对象。
		and Duel.IsExistingTarget(c31930787.eqfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 给玩家显示选择提示，提示信息为“请选择要装备的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择对方场上1只满足条件的同调怪兽作为效果对象，并设定为当前连锁的取对象目标。
	local g=Duel.SelectTarget(tp,c31930787.eqfilter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 装备限制函数：该装备卡只能装备给效果的持有者（即机皇帝神空∞自身），保证被装备的怪兽只可以贴给这张卡。
function c31930787.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 装备处理：获取对象怪兽，确认其仍表侧且与效果关联后，以其原本攻击力装备给这张卡，并注册装备限制与攻击力提升效果。
function c31930787.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中第一个选择的对象（即被装备的同调怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) then
		local atk=tc:GetTextAttack()
		if atk<0 then atk=0 end
		-- 执行装备操作：将对象怪兽作为装备卡装备给机皇帝；若装备失败则终止处理。
		if not Duel.Equip(tp,tc,c,false) then return end
		-- 那只对方同调怪兽给这张卡装备。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c31930787.eqlimit)
		tc:RegisterEffect(e1)
		if atk>0 then
			-- ③：这个攻击力上升自身的效果装备的怪兽的攻击力数值。
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
-- ④的发动条件：当前为我的主要阶段1，且这张卡没有已经持有直接攻击效果。
function c31930787.dircon(e,tp,eg,ep,ev,re,r,rp)
	-- 条件具体判断：阶段必须是主要阶段1，并且本卡尚未获得EFFECT_DIRECT_ATTACK效果。
	return Duel.GetCurrentPhase()==PHASE_MAIN1 and not e:GetHandler():IsHasEffect(EFFECT_DIRECT_ATTACK)
end
-- cost过滤器：用于选择送去墓地的装备卡，要求其原本类型为怪兽且能够作为cost送去墓地。
function c31930787.dcfilter(c)
	return bit.band(c:GetOriginalType(),TYPE_MONSTER)~=0 and c:IsAbleToGraveAsCost()
end
-- cost支付：从这张卡装备的怪兽卡中选择1只满足条件的送往墓地作为发动代价。
function c31930787.dircost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetEquipGroup():IsExists(c31930787.dcfilter,1,nil) end
	-- 显示选择提示，提示信息为“请选择要送去墓地的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local g=e:GetHandler():GetEquipGroup():FilterSelect(tp,c31930787.dcfilter,1,1,nil)
	-- 将选择的装备怪兽送入墓地，作为效果的cost（REASON_COST）。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果处理：为本卡附加一个可以直接攻击的效果，持续到回合结束，且该效果不能被无效。
function c31930787.dirop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 这个回合这张卡可以直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1,true)
end
