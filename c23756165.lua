--魅惑の女王 LV5
-- 效果：
-- ①：这张卡是已用「魅惑的女王 LV3」的效果特殊召唤的场合，1回合1次，以对方场上1只5星以下的怪兽为对象才能发动。那只5星以下的对方怪兽当作装备魔法卡使用给这张卡装备（只有1只可以装备）。
-- ②：这张卡被战斗破坏的场合，作为代替把这张卡的效果装备的怪兽破坏。
-- ③：自己准备阶段，把用这张卡的效果把怪兽装备的这张卡送去墓地才能发动。从手卡·卡组把1只「魅惑的女王 LV7」特殊召唤。
local s,id,o=GetID()
-- 注册本卡的全部效果：记录LV3召唤来源、装备效果（含一速与二速变体）、准备阶段升级特殊召唤。
function c23756165.initial_effect(c)
	-- 登记本卡效果文中提到的「魅惑的女王 LV3」和「魅惑的女王 LV7」，以便相关效果关联查询。
	aux.AddCodeList(c,87257460,50140163)
	-- ①：这张卡是已用「魅惑的女王 LV3」的效果特殊召唤的场合
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetOperation(c23756165.regop)
	c:RegisterEffect(e1)
	-- ①：这张卡是已用「魅惑的女王 LV3」的效果特殊召唤的场合，1回合1次，以对方场上1只5星以下的怪兽为对象才能发动。那只5星以下的对方怪兽当作装备魔法卡使用给这张卡装备（只有1只可以装备）。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(23756165,0))  --"装备"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e2:SetCondition(c23756165.eqcon1)
	e2:SetTarget(c23756165.eqtg)
	e2:SetOperation(c23756165.eqop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCondition(c23756165.eqcon2)
	c:RegisterEffect(e3)
	-- ③：自己准备阶段，把用这张卡的效果把怪兽装备的这张卡送去墓地才能发动。从手卡·卡组把1只「魅惑的女王 LV7」特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(23756165,1))  --"特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e4:SetCondition(c23756165.spcon)
	e4:SetCost(c23756165.spcost)
	e4:SetTarget(c23756165.sptg)
	e4:SetOperation(c23756165.spop)
	c:RegisterEffect(e4)
end
c23756165.lvup={50140163,87257460}
c23756165.lvdn={87257460}
-- 特殊召唤成功时记录召唤来源：若召唤信息中的卡号为87257460（即由「魅惑的女王 LV3」的效果特殊召唤），则给自己注册标志位，用于后续条件判断。
function c23756165.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetSpecialSummonInfo(SUMMON_INFO_CODE)==87257460 then
		c:RegisterFlagEffect(id+1,RESET_EVENT+RESETS_STANDARD,0,1)
	end
end
-- 一速装备效果的发动条件：需持有LV3召唤来源标志、场上不存在本效果装备的怪兽，并且当前未被赋予二速发动时机。
function c23756165.eqcon1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判定一速装备效果可发：具有LV3召唤标志、未装备自身效果怪兽，且不能被作为二速效果发动。
	return c:GetFlagEffect(id+1)>0 and not aux.IsSelfEquip(c,FLAG_ID_ALLURE_QUEEN) and not aux.IsCanBeQuickEffect(c,tp,95937545)
end
-- 二速装备效果的发动条件：与一速条件相同，但要求当前可被作为二速效果发动（因此使用快速效果连锁）。
function c23756165.eqcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判定二速装备效果可发：具有LV3召唤标志、未装备自身效果怪兽，且当前可被作为二速效果发动。
	return c:GetFlagEffect(id+1)>0 and not aux.IsSelfEquip(c,FLAG_ID_ALLURE_QUEEN) and aux.IsCanBeQuickEffect(c,tp,95937545)
end
-- 对象筛选条件：对方场上的表侧表示5星以下怪兽，且能够变更控制权（可被当作装备卡装备过来）。
function c23756165.filter(c)
	return c:IsLevelBelow(5) and c:IsFaceup() and c:IsAbleToChangeControler()
end
-- 装备效果的目标选择与合法性判定：检查对象为对方怪兽且满足条件；发动时需魔陷区有空位且存在可装备对象，然后选择1只。
function c23756165.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c23756165.filter(chkc) end
	-- 发动时检查：我方魔陷区需有至少1个空位（用于放置装备卡）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 发动时检查：对方场上存在至少1只满足条件的表侧5星以下怪兽。
		and Duel.IsExistingTarget(c23756165.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示当前玩家选择要装备的卡（显示“请选择要装备的卡”）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 从对方怪兽区域选择1只符合条件的怪兽，并将其登记为本次连锁的取对象。
	local g=Duel.SelectTarget(tp,c23756165.filter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 装备限制函数：该装备卡只能装备给效果持有者（本卡），不能转移到其他怪兽。
function c23756165.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 装备效果处理：取对象怪兽若仍表侧且与效果关联，则将其作为装备魔法卡装备给本卡，并为该怪兽附加装备对象限制和代替破坏效果。
function c23756165.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local atk=tc:GetTextAttack()
		local def=tc:GetTextDefense()
		if atk<0 then atk=0 end
		if def<0 then def=0 end
		-- 尝试将对象怪兽作为装备卡装备给本卡；装备失败则终止后续处理。
		if not Duel.Equip(tp,tc,c,false) then return end
		tc:RegisterFlagEffect(FLAG_ID_ALLURE_QUEEN,RESET_EVENT+RESETS_STANDARD,0,0,id)
		-- 那只5星以下的对方怪兽当作装备魔法卡使用给这张卡装备
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c23756165.eqlimit)
		tc:RegisterEffect(e1)
		-- ②：这张卡被战斗破坏的场合，作为代替把这张卡的效果装备的怪兽破坏。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_OWNER_RELATE)
		e2:SetCode(EFFECT_DESTROY_SUBSTITUTE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetValue(c23756165.repval)
		tc:RegisterEffect(e2)
	end
end
-- 代替破坏的判定函数：仅当破坏原因为战斗破坏时，才用装备怪兽代替。
function c23756165.repval(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0
end
-- 升级效果③的发动条件：当前为持有者自己的准备阶段，且本卡正装备着用自身效果装备的怪兽。
function c23756165.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 确认是己方准备阶段，且本卡存在由自身效果装备的怪兽。
	return Duel.GetTurnPlayer()==tp and aux.IsSelfEquip(e:GetHandler(),FLAG_ID_ALLURE_QUEEN)
end
-- 升级效果③的发动代价：将装备着怪兽的本卡作为cost送去墓地；同时检查其可作为cost送墓。
function c23756165.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 执行cost：把本卡送入墓地。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 特殊召唤对象的筛选条件：卡名为「魅惑的女王 LV7」，且可以被tp玩家特殊召唤（符合升级召唤条件）。
function c23756165.spfilter(c,e,tp)
	return c:IsCode(50140163) and c:IsCanBeSpecialSummoned(e,SUMMON_VALUE_LV,tp,true,false)
end
-- 升级效果③的发动目标判定：确认有可用的怪兽区域，并检查手卡·卡组存在可特殊召唤的「魅惑的女王 LV7」，同时设置特殊召唤操作信息。
function c23756165.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查：因本卡会作为cost送墓，允许当前怪兽区空位为0即可发动。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 发动时检查：手卡或卡组中存在满足条件的「魅惑的女王 LV7」。
		and Duel.IsExistingMatchingCard(c23756165.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置本次连锁的特殊召唤操作信息：将从手卡·卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 升级效果③处理：若怪兽区域有空位，从手卡·卡组选择1只「魅惑的女王 LV7」表侧攻击表示特殊召唤。
function c23756165.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认：如果我方怪兽区域没有可用空位，则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示当前玩家选择要特殊召唤的卡（显示“请选择要特殊召唤的卡”）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡·卡组选择1只符合条件的「魅惑的女王 LV7」。
	local g=Duel.SelectMatchingCard(tp,c23756165.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选择的「魅惑的女王 LV7」表侧攻击表示特殊召唤到我方场上（无视召唤条件，按升级规则处理）。
		Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
	end
end
