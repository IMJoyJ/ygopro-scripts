--誘いのΔ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这个卡名的②③的效果1回合各能使用1次。
-- ①：作为这张卡的发动时的效果处理，可以从卡组把1只5星以上的不死族怪兽送去墓地。
-- ②：场上有不死族怪兽存在的场合才能发动。在自己场上把1只「Δ衍生物」（不死族·暗·5星·攻/守0）特殊召唤。
-- ③：这张卡在墓地存在的状态，怪兽从墓地加入手卡的场合才能发动。这张卡加入手卡。
local s,id,o=GetID()
-- 初始化函数：创建并注册①（发动时从卡组堆墓不死族）、②（场上有不死族时特招Δ衍生物）、③（墓地存在时怪兽从墓地回手则自身加入手卡）三个效果。
function s.initial_effect(c)
	-- ①：作为这张卡的发动时的效果处理，可以从卡组把1只5星以上的不死族怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：场上有不死族怪兽存在的场合才能发动。在自己场上把1只「Δ衍生物」（不死族·暗·5星·攻/守0）特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.tkcon)
	e2:SetTarget(s.tktg)
	e2:SetOperation(s.tkop)
	c:RegisterEffect(e2)
	-- ③：这张卡在墓地存在的状态，怪兽从墓地加入手卡的场合才能发动。这张卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"加入手卡"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_HAND)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id+o*2)
	e3:SetCondition(s.thcon)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
-- 过滤函数：判断卡是否满足“不死族、5星以上、可送去墓地”的条件，用于①效果选择送墓的卡。
function s.tgfilter(c)
	return c:IsRace(RACE_ZOMBIE) and c:IsLevelAbove(5) and c:IsAbleToGrave()
end
-- ①效果的处理函数：从卡组挑选1只符合条件的不死族怪兽送去墓地；若卡组没有可选怪兽或玩家取消则不处理。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取我方卡组中所有满足tgfilter条件（5星以上不死族且能送去墓地）的怪兽，作为可选集合。
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_DECK,0,nil)
	-- 若存在可选怪兽且玩家确认要送墓，则继续执行选择；否则效果不处理。
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否把卡送去墓地？"
		-- 发送选择提示，让玩家选择要送去墓地的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选择的怪兽以效果原因送去墓地。
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
end
-- ②效果的发动条件函数：检查双方场上是否存在表侧表示的不死族怪兽。
function s.tkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查双方场上是否存在至少1张表侧表示的不死族怪兽。
	return Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsRace),tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,RACE_ZOMBIE)
end
-- ②效果的发动目标函数：在发动时检查自己能否空出怪兽区并能否特殊召唤Δ衍生物。
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的主要怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认玩家可以特殊召唤「Δ衍生物」（不死族·暗·5星·攻/守0）到自己场上。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,0,0,5,RACE_ZOMBIE,ATTRIBUTE_DARK,POS_FACEUP) end
	-- 登记本次操作包含特殊召唤衍生物类别的信息。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 登记本次操作包含特殊召唤类别的信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- ②效果的实际处理函数：在自己场上特殊召唤1只「Δ衍生物」。
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果处理时再次确认自己场上是否有空位，若无则处理失败。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		-- 同时确认玩家仍能特殊召唤衍生物，否则不处理。
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,0,0,5,RACE_ZOMBIE,ATTRIBUTE_DARK,POS_FACEUP) then return end
	-- 生成1只「Δ衍生物」（不死族·暗·5星·攻/守0）。
	local token=Duel.CreateToken(tp,id+o)
	-- 将衍生物以表侧表示特殊召唤到自己场上。
	Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
end
-- ③效果的触发过滤函数：判断加入手卡的卡是否为怪兽且是从墓地加入手卡。
function s.trigfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsPreviousLocation(LOCATION_GRAVE)
end
-- ③效果的发动条件：本连锁触发事件中存在从墓地加入手卡的怪兽。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.trigfilter,1,nil)
end
-- ③效果的目标检查与登记：确认本卡能加入手卡并设置回手操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 登记本次操作包含将这张卡加入手卡的信息。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- ③效果的实际处理：将这张卡加入持有者手卡并向对方展示。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡仍与该效果关联且不受“王家长眠之谷”等效果影响后，才处理回手。
	if c:IsRelateToEffect(e) and aux.NecroValleyFilter()(c) then
		-- 将这张卡加入持有者手卡。
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		-- 向对方玩家展示这张卡，确认其已加入手卡。
		Duel.ConfirmCards(1-tp,c)
	end
end
