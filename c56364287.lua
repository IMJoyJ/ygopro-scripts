--サイバー・ドラゴン・ヘルツ
-- 效果：
-- 这个卡名的②③的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡的卡名只要在场上·墓地存在当作「电子龙」使用。
-- ②：这张卡特殊召唤的场合才能发动。这张卡的等级直到回合结束时变成5星。这个效果的发动后，直到回合结束时自己不是机械族怪兽不能特殊召唤。
-- ③：这张卡被送去墓地的场合才能发动。从自己的卡组·墓地把这张卡以外的1只「电子龙」加入手卡。
function c56364287.initial_effect(c)
	-- 在场上·墓地将这张卡的卡名当作「电子龙」使用。
	aux.EnableChangeCode(c,70095154,LOCATION_MZONE+LOCATION_GRAVE)
	-- ②：这张卡特殊召唤的场合才能发动。这张卡的等级直到回合结束时变成5星。这个效果的发动后，直到回合结束时自己不是机械族怪兽不能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(56364287,0))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,56364287)
	e2:SetTarget(c56364287.lvtg)
	e2:SetOperation(c56364287.lvop)
	c:RegisterEffect(e2)
	-- ③：这张卡被送去墓地的场合才能发动。从自己的卡组·墓地把这张卡以外的1只「电子龙」加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(56364287,2))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,56364287)
	e3:SetTarget(c56364287.thtg)
	e3:SetOperation(c56364287.thop)
	c:RegisterEffect(e3)
end
-- 效果②的发动条件检测：检查自身等级是否不为5星。
function c56364287.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsLevel(5) end
end
-- 效果②的执行函数：将自身等级直到回合结束时变成5星，并适用直到回合结束时自己不是机械族怪兽不能特殊召唤的限制。
function c56364287.lvop(e,tp,eg,ep,ev,re,r,rp,c)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 这张卡的等级直到回合结束时变成5星。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(5)
		c:RegisterEffect(e1)
	end
	-- 这个效果的发动后，直到回合结束时自己不是机械族怪兽不能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetTargetRange(1,0)
	e2:SetLabelObject(e)
	e2:SetTarget(c56364287.splimit)
	-- 向玩家注册不能特殊召唤机械族以外怪兽的限制效果。
	Duel.RegisterEffect(e2,tp)
end
-- 特殊召唤限制的过滤函数：限制不能特殊召唤非机械族的怪兽。
function c56364287.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsRace(RACE_MACHINE)
end
-- 检索/回收「电子龙」的过滤条件：卡名为「电子龙」且可以加入手卡。
function c56364287.thfilter(c)
	return c:IsCode(70095154) and c:IsAbleToHand()
end
-- 效果③的发动准备与检测：检查卡组·墓地是否存在除自身以外的「电子龙」，并设置检索/回收的操作信息。
function c56364287.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的卡组或墓地是否存在至少1张除自身以外的「电子龙」。
	if chk==0 then return Duel.IsExistingMatchingCard(c56364287.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 设置连锁处理的操作信息：从卡组或墓地将1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果③的执行函数：从卡组·墓地选择1只「电子龙」加入手卡，并给对方确认。
function c56364287.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家发送提示信息：“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组或墓地（受王家之谷影响）选择1张除自身以外的「电子龙」。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c56364287.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,e:GetHandler())
	if g:GetCount()>0 then
		-- 因效果将选择的卡加入手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
