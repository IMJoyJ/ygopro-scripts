--めぐり－Ai－
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：把手卡·额外卡组1只攻击力2300的电子界族怪兽给对方观看，把持有和那只怪兽相同属性的1只「@火灵天星」怪兽从卡组加入手卡。发动后，这个回合中自己对这个效果给人观看的怪兽或者那些同名怪兽的特殊召唤没有成功的场合，结束阶段让自己受到2300伤害。这张卡的发动后，直到回合结束时自己不能把电子界族以外的怪兽的效果发动。
function c6552971.initial_effect(c)
	-- ①：把手卡·额外卡组1只攻击力2300的电子界族怪兽给对方观看，把持有和那只怪兽相同属性的1只「@火灵天星」怪兽从卡组加入手卡。发动后，这个回合中自己对这个效果给人观看的怪兽或者那些同名怪兽的特殊召唤没有成功的场合，结束阶段让自己受到2300伤害。这张卡的发动后，直到回合结束时自己不能把电子界族以外的怪兽的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,6552971+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c6552971.target)
	e1:SetOperation(c6552971.activate)
	c:RegisterEffect(e1)
end
-- 过滤手卡·额外卡组中未公开的、攻击力为2300的电子界族怪兽，且卡组中存在与其相同属性的「@火灵天星」怪兽
function c6552971.chkfilter(c,tp)
	return c:IsRace(RACE_CYBERSE) and c:GetAttack()==2300 and not c:IsPublic()
		-- 检查卡组中是否存在与该怪兽相同属性的、可加入手卡的「@火灵天星」怪兽
		and Duel.IsExistingMatchingCard(c6552971.thfilter,tp,LOCATION_DECK,0,1,nil,c:GetAttribute())
end
-- 过滤卡组中与指定属性相同、可加入手卡的「@火灵天星」怪兽
function c6552971.thfilter(c,att)
	return c:IsSetCard(0x135) and c:IsAttribute(att) and c:IsAbleToHand()
end
-- 效果发动时的落点/目标选择与操作信息注册
function c6552971.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡·额外卡组是否存在满足条件的、可给对方观看的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c6552971.chkfilter,tp,LOCATION_HAND+LOCATION_EXTRA,0,1,nil,tp) end
	-- 设置操作信息为“从卡组将1张卡加入手卡”
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理的核心逻辑，包括展示怪兽、注册特殊召唤检测、注册结束阶段伤害效果、检索卡片以及注册怪兽效果发动限制
function c6552971.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要给对方确认的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 让玩家从手卡·额外卡组选择1只满足条件的电子界族怪兽
	local rc=Duel.SelectMatchingCard(tp,c6552971.chkfilter,tp,LOCATION_HAND+LOCATION_EXTRA,0,1,1,nil,tp):GetFirst()
	if rc then
		local att=rc:GetAttribute()
		-- 给对方玩家确认选择的怪兽
		Duel.ConfirmCards(1-tp,rc)
		-- 如果展示的怪兽来自手卡，则洗切手卡
		if rc:IsLocation(LOCATION_HAND) then Duel.ShuffleHand(tp) end
		-- 这个回合中自己对这个效果给人观看的怪兽或者那些同名怪兽的特殊召唤没有成功的场合
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_SPSUMMON_SUCCESS)
		e1:SetLabel(rc:GetCode())
		e1:SetOperation(c6552971.regop)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 注册用于检测展示怪兽（或其同名卡）是否成功特殊召唤的全局事件监听效果
		Duel.RegisterEffect(e1,tp)
		-- 把持有和那只怪兽相同属性的1只「@火灵天星」怪兽从卡组加入手卡。发动后，...结束阶段让自己受到2300伤害。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_PHASE+PHASE_END)
		e2:SetCountLimit(1)
		e2:SetReset(RESET_PHASE+PHASE_END)
		e2:SetCondition(c6552971.damcon)
		e2:SetOperation(c6552971.damop)
		e2:SetLabelObject(e1)
		-- 注册在结束阶段触发伤害判定的全局效果
		Duel.RegisterEffect(e2,tp)
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从卡组选择1只与展示怪兽相同属性的「@火灵天星」怪兽
		local g=Duel.SelectMatchingCard(tp,c6552971.thfilter,tp,LOCATION_DECK,0,1,1,nil,att)
		if #g>0 then
			-- 将选择的「@火灵天星」怪兽加入手卡
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 给对方玩家确认加入手卡的卡片
			Duel.ConfirmCards(1-tp,g)
		end
	end
	-- 这张卡的发动后，直到回合结束时自己不能把电子界族以外的怪兽的效果发动。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetTargetRange(1,0)
	e3:SetValue(c6552971.actlimit)
	e3:SetReset(RESET_PHASE+PHASE_END)
	-- 注册“直到回合结束时自己不能把电子界族以外的怪兽的效果发动”的玩家限制效果
	Duel.RegisterEffect(e3,tp)
end
-- 过滤由自己特殊召唤的、且卡名与展示怪兽相同的怪兽
function c6552971.regfilter(c,tp,code)
	return c:IsSummonPlayer(tp) and c:IsCode(code)
end
-- 特殊召唤成功时的处理：如果特殊召唤了展示的怪兽或其同名卡，则将标记值设为0（表示已成功特殊召唤，免除伤害）
function c6552971.regop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then return end
	if eg:IsExists(c6552971.regfilter,1,nil,tp,e:GetLabel()) then
		e:SetLabel(0)
	end
end
-- 结束阶段伤害效果的触发条件：检测标记值不为0（即本回合未成功特殊召唤展示的怪兽或其同名卡）
function c6552971.damcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabelObject():GetLabel()~=0
end
-- 结束阶段伤害效果的处理：给自己造成2300点伤害
function c6552971.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 给予玩家2300点效果伤害
	Duel.Damage(tp,2300,REASON_EFFECT)
end
-- 限制效果发动的过滤条件：非电子界族的怪兽效果
function c6552971.actlimit(e,re,rp)
	local rc=re:GetHandler()
	return re:IsActiveType(TYPE_MONSTER) and not rc:IsRace(RACE_CYBERSE)
end
