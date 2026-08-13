--ミミグル・スローン
-- 效果：
-- 1星「迷拟宝箱鬼」怪兽×2
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：把这张卡1个超量素材取除才能发动。从自己的手卡·卡组·墓地把1只「迷拟宝箱鬼·领主」特殊召唤。
-- ②：自己·对方的主要阶段，以自己场上1只「迷拟宝箱鬼·领主」为对象才能发动。这张卡当作攻击力上升1000的装备魔法卡使用给那只怪兽装备。那之后，可以让最多有这张卡持有的超量素材数量的场上的卡回到手卡。
local s,id,o=GetID()
-- 初始化函数：为这张卡注册卡名记载、超量召唤手续、苏生限制，以及①②两个效果的创建与注册。
function s.initial_effect(c)
	-- 记录这张卡的效果文本中记载了卡名「迷拟宝箱鬼·领主」（55537983），用于相关检索/判断。
	aux.AddCodeList(c,55537983)
	-- 设置超量召唤手续：以1星「迷拟宝箱鬼」怪兽2只为素材进行超量召唤（种族字段0x1b7）。
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x1b7),1,2)
	c:EnableReviveLimit()
	-- ①：把这张卡1个超量素材取除才能发动。从自己的手卡·卡组·墓地把1只「迷拟宝箱鬼·领主」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：自己·对方的主要阶段，以自己场上1只「迷拟宝箱鬼·领主」为对象才能发动。这张卡当作攻击力上升1000的装备魔法卡使用给那只怪兽装备。那之后，可以让最多有这张卡持有的超量素材数量的场上的卡回到手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"装备"
	e2:SetCategory(CATEGORY_EQUIP+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.eqcon)
	e2:SetTarget(s.eqtg)
	e2:SetOperation(s.eqop)
	c:RegisterEffect(e2)
end
-- 发动①效果的COST：把自己场上这张卡的1个超量素材取除。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 特殊召唤的过滤条件：选择「迷拟宝箱鬼·领主」，且该卡可以被玩家tp不作特殊召唤限制地表侧表示特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsCode(55537983) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
-- 发动①的合法判定：自己主要怪兽区有空位，且手卡·卡组·墓地存在符合条件的「迷拟宝箱鬼·领主」。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上的主要怪兽区是否有可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡·卡组·墓地是否存在至少1只符合条件的「迷拟宝箱鬼·领主」。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息：本次处理将从手卡·卡组·墓地特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE)
end
-- ①效果处理：从自己的手卡·卡组·墓地选1只「迷拟宝箱鬼·领主」特殊召唤，且需通过王家长眠之谷的适用判定。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认自己主要怪兽区有空位，否则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 显示“请选择要特殊召唤的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 实际从手卡·卡组·墓地选择1只符合条件的「迷拟宝箱鬼·领主」，并排除因王家长眠之谷不能特殊召唤的卡。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选择的「迷拟宝箱鬼·领主」表侧攻击表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的发动条件：仅在控制者的主要阶段1或主要阶段2可以发动。
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段是否为主要阶段1或主要阶段2。
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- ②效果对象的过滤条件：必须是卡名「迷拟宝箱鬼·领主」。
function s.eqfilter(c)
	return c:IsCode(55537983)
end
-- ②效果的发动判定：自己魔陷区有空位，并且自己场上有1只「迷拟宝箱鬼·领主」能成为对象。
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.eqfilter(chkc) end
	-- 检查自己后场（魔陷区）是否有可用空格，用于装备卡的放置。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查自己场上是否存在可成为对象的「迷拟宝箱鬼·领主」（本卡自身除外）。
		and Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 显示“请选择要装备的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己场上1只「迷拟宝箱鬼·领主」作为效果对象并记录。
	Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
	-- 设置操作信息：本卡的张卡将被作为装备魔法卡装备（CATEGORY_EQUIP）。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- ②效果处理：把这张卡当作装备卡装备给对象怪兽，赋予其攻击力上升1000，并可选让场上卡回到手牌。
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	local ct=c:GetOverlayCount()
	-- 获取①效果选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 处理时判定装备条件：魔陷区有空位、此卡仍由自己控制、对象怪兽仍表侧表示且与效果关联，否则装备处理失败。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or c:GetControler()==1-tp or tc:IsFacedown() or not tc:IsRelateToEffect(e) then
		-- 装备条件不满足时，将此卡送去墓地（作为装备处理失败的归属）。
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 尝试将此卡作为装备魔法卡装备给对象怪兽；如果装备失败则结束处理。
	if not Duel.Equip(tp,c,tc) then return end
	-- 给那只怪兽装备：设置该装备卡的装备限制效果，使这张卡只能装备给所选择的那只「迷拟宝箱鬼·领主」。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(s.eqlimit)
	e1:SetLabelObject(tc)
	c:RegisterEffect(e1)
	-- 攻击力上升1000：作为装备卡期间，为装备怪兽提供1000点攻击力提升。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(1000)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2)
	-- 若此卡持有超量素材且场上有可回手的卡，则询问玩家是否让卡回到手牌；玩家选择“是”时才继续回手处理。
	if ct>0 and Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否让卡回到手卡？"
		-- 显示“请选择要返回手牌的卡”的提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
		-- 选择场上1至超量素材数量张可返回手牌的卡。
		local sg=Duel.SelectMatchingCard(tp,Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,ct,nil)
		if #sg>0 then
			-- 中断当前效果链，使后续的返回手牌处理作为独立处理进行，避免错过时点。
			Duel.BreakEffect()
			-- 显示被选中回手的卡的动画，并将这些卡记录为本效果的关联对象。
			Duel.HintSelection(sg)
			-- 将选择的卡以效果原因返回持有者的手牌。
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
		end
	end
end
-- 装备限制判定：只有效果指定装备的那只「迷拟宝箱鬼·领主」才能装备这张卡。
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end
