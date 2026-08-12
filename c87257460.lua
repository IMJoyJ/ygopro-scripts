--魅惑の女王 LV3
-- 效果：
-- ①：1回合1次，以对方场上1只3星以下的怪兽为对象才能发动。那只3星以下的对方怪兽当作装备魔法卡使用给这张卡装备（只有1只可以装备）。
-- ②：这张卡被战斗破坏的场合，作为代替把这张卡的效果装备的怪兽破坏。
-- ③：自己准备阶段，把用这张卡的效果把怪兽装备的这张卡送去墓地才能发动。从手卡·卡组把1只「魅惑的女王 LV5」特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果：①装备对方怪兽的效果（包含起动效果与因其他卡片效果转成的即时效果），③准备阶段送墓特殊召唤「魅惑的女王 LV5」的效果。
function c87257460.initial_effect(c)
	-- 注册该卡在效果中记载了「魅惑的女王 LV3」与「魅惑的女王 LV5」的卡名。
	aux.AddCodeList(c,87257460,23756165)
	-- ①：1回合1次，以对方场上1只3星以下的怪兽为对象才能发动。那只3星以下的对方怪兽当作装备魔法卡使用给这张卡装备（只有1只可以装备）。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(87257460,0))  --"装备"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e1:SetCondition(c87257460.eqcon1)
	e1:SetTarget(c87257460.eqtg)
	e1:SetOperation(c87257460.eqop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCondition(c87257460.eqcon2)
	c:RegisterEffect(e2)
	-- ③：自己准备阶段，把用这张卡的效果把怪兽装备的这张卡送去墓地才能发动。从手卡·卡组把1只「魅惑的女王 LV5」特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(87257460,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetCondition(c87257460.spcon)
	e3:SetCost(c87257460.spcost)
	e3:SetTarget(c87257460.sptg)
	e3:SetOperation(c87257460.spop)
	c:RegisterEffect(e3)
end
c87257460.lvup={23756165}
-- 装备效果（起动效果版本）的发动条件判定函数。
function c87257460.eqcon1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判定自身当前没有通过自身效果装备怪兽，且当前不满足将该效果转为即时效果的条件。
	return not aux.IsSelfEquip(c,FLAG_ID_ALLURE_QUEEN) and not aux.IsCanBeQuickEffect(c,tp,95937545)
end
-- 装备效果（即时效果版本）的发动条件判定函数。
function c87257460.eqcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判定自身当前没有通过自身效果装备怪兽，且当前满足将该效果转为即时效果的条件。
	return not aux.IsSelfEquip(c,FLAG_ID_ALLURE_QUEEN) and aux.IsCanBeQuickEffect(c,tp,95937545)
end
-- 过滤对方场上表侧表示、等级3以下且可以转移控制权的怪兽。
function c87257460.filter(c)
	return c:IsLevelBelow(3) and c:IsFaceup() and c:IsAbleToChangeControler()
end
-- 装备效果的发动准备（检查合法性并选择对象）。
function c87257460.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c87257460.filter(chkc) end
	-- 判定自己魔法与陷阱区域是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判定对方场上是否存在至少1只满足条件的怪兽。
		and Duel.IsExistingTarget(c87257460.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择对方场上1只满足条件的怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c87257460.filter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 装备限制判定函数（限制只能装备给当前卡片）。
function c87257460.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 装备效果的处理函数（执行装备、注册装备关系及代破效果）。
function c87257460.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动时选择的效果对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 将目标怪兽作为装备卡装备给自身，若装备失败则结束处理。
		if not Duel.Equip(tp,tc,c,false) then return end
		tc:RegisterFlagEffect(FLAG_ID_ALLURE_QUEEN,RESET_EVENT+RESETS_STANDARD,0,0,id)
		-- （只有1只可以装备）
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c87257460.eqlimit)
		tc:RegisterEffect(e1)
		-- ②：这张卡被战斗破坏的场合，作为代替把这张卡的效果装备的怪兽破坏。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_DESTROY_SUBSTITUTE)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_OWNER_RELATE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetValue(c87257460.repval)
		tc:RegisterEffect(e2)
	end
end
-- 判定破坏原因是否为战斗破坏。
function c87257460.repval(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0
end
-- 特殊召唤效果的发动条件判定（必须是自己的准备阶段，且自身有通过自身效果装备怪兽）。
function c87257460.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前是否为自己的回合，且自身当前装备着由自身效果装备的怪兽。
	return Duel.GetTurnPlayer()==tp and aux.IsSelfEquip(e:GetHandler(),FLAG_ID_ALLURE_QUEEN)
end
-- 特殊召唤效果的发动代价处理函数（将自身送去墓地）。
function c87257460.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将自身作为发动代价送去墓地。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 过滤手卡或卡组中可以特殊召唤的「魅惑的女王 LV5」。
function c87257460.spfilter(c,e,tp)
	return c:IsCode(23756165) and c:IsCanBeSpecialSummoned(e,SUMMON_VALUE_LV,tp,true,false)
end
-- 特殊召唤效果的发动准备（检查怪兽区域空位及是否存在可特召的卡，并设置操作信息）。
function c87257460.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定自己场上是否有可用的怪兽区域空位（由于自身作为发动代价会送去墓地释放1个格子，因此判定条件为大于-1）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 判定自己的手卡或卡组中是否存在至少1只满足特殊召唤条件的「魅惑的女王 LV5」。
		and Duel.IsExistingMatchingCard(c87257460.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置当前连锁的操作信息为特殊召唤手卡或卡组的怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 特殊召唤效果的处理函数（从手卡或卡组特殊召唤「魅惑的女王 LV5」）。
function c87257460.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前自己场上是否有可用的怪兽区域空位，若无则结束处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡或卡组选择1只「魅惑的女王 LV5」。
	local g=Duel.SelectMatchingCard(tp,c87257460.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选择的怪兽以表侧表示特殊召唤（无视召唤条件）。
		Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
	end
end
