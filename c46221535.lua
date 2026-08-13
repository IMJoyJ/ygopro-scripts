--ドリル・アームド・ドラゴン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从手卡把这张卡和1只风属性怪兽送去墓地才能发动。这个回合中，自己场上的龙族·风属性怪兽的攻击力上升300。
-- ②：从自己墓地把风属性或7星以上的龙族怪兽任意数量除外才能发动。把持有和除外的怪兽数量相同等级的1只「钻头武装龙」以外的龙族怪兽从卡组加入手卡。
local s,id,o=GetID()
-- 初始化卡片效果：为这张卡注册两个1回合1次的起动效果。①效果在手牌发动，以这张卡和手卡1只风属性怪兽为COST送墓，使己方龙族·风属性怪兽攻击力上升300；②效果在场上发动，除外墓地中任意数量的风属性或7星以上龙族怪兽，从卡组将1只等级与除外数量相同的「钻头武装龙」以外的龙族怪兽加入手卡。
function s.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：从手卡把这张卡和1只风属性怪兽送去墓地才能发动。这个回合中，自己场上的龙族·风属性怪兽的攻击力上升300。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"攻击力上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.atkcost)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
	-- ②：从自己墓地把风属性或7星以上的龙族怪兽任意数量除外才能发动。把持有和除外的怪兽数量相同等级的1只「钻头武装龙」以外的龙族怪兽从卡组加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"检索"
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 效果①的COST筛选函数：判断手卡中的怪兽是否为风属性且可以作为COST送入墓地，用于选择作为COST的风属性怪兽。
function s.costfilter(c)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsAbleToGraveAsCost()
end
-- 效果①的COST检查：在check阶段确认这张卡自身能否作为COST送墓，且手卡中存在1只除此卡外的可送墓风属性怪兽；若满足则允许发动。
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() and
		-- 检查己方手卡中是否存在1张除这张卡以外的、可作为COST送去墓地的风属性怪兽（作为效果①COST的一部分）。
		Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,c) end
	-- 向己方玩家显示“请选择要送去墓地的卡”的选择提示，用于选择COST怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让己方玩家从手卡选择1张除此卡外的、可作为COST的风属性怪兽，返回所选的怪兽组。
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,c)
	g:AddCard(c)
	-- 将COST怪兽组g（包含这张卡和选择的风属性怪兽）作为效果①的COST一同送去墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果①的处理：创建攻击力上升的领域效果，使己方场上的龙族·风属性怪兽攻击力上升300，并持续到回合结束。
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- ②：从自己墓地把风属性或7星以上的龙族怪兽任意数量除外才能发动。把持有和除外的怪兽数量相同等级的1只「钻头武装龙」以外的龙族怪兽从卡组加入手卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.atktg)
	e1:SetValue(300)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将创建的攻击力上升效果e1注册到当前玩家tp的场上，使其在tp的怪兽区域生效，直到回合结束。
	Duel.RegisterEffect(e1,tp)
end
-- 定义攻击力上升效果的目标对象条件：己方场上的怪兽必须同时满足龙族和风属性才会受到攻击力上升。
function s.atktg(e,c)
	return c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_WIND)
end
-- 效果②的除外COST筛选函数：判断墓地中的怪兽是否为龙族，且满足风属性或7星以上，并可以作为COST除外。
function s.cfilter(c)
	return c:IsRace(RACE_DRAGON) and (c:IsLevelAbove(7) or c:IsAttribute(ATTRIBUTE_WIND)) and c:IsAbleToRemoveAsCost()
end
-- 定义选择除外组的合法性判断：在检索目标组tg中是否存在等级等于候选除外组g卡片数量的龙族怪兽，确保除外数量与检索等级匹配。
function s.fselect(g,tg)
	return tg:IsExists(Card.IsLevel,1,nil,#g)
end
-- 效果②的检索目标筛选函数：卡组中的龙族怪兽，卡名不是「钻头武装龙」自身，且拥有等级，并能加入手卡。
function s.thfilter(c)
	return not c:IsCode(id) and c:IsLevelAbove(1) and c:IsRace(RACE_DRAGON)
		and c:IsAbleToHand()
end
-- 效果②的发动条件与COST处理：获取墓地可除外的龙族怪兽组和卡组可检索的龙族怪兽组，计算最大可选数量；check时确认存在合法选择；正式处理时让玩家选择任意数量符合条件的龙族怪兽除外，记录除外数量，并设置后续检索加入手卡的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取己方墓地中可作为效果②COST除外的龙族怪兽（风属性或7星以上）集合。
	local cg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_GRAVE,0,nil)
	-- 获取己方卡组中可作为效果②检索对象的龙族怪兽（不是「钻头武装龙」、有等级、能加入手卡）集合。
	local tg=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	local _,maxlv=tg:GetMaxGroup(Card.GetLevel)
	if chk==0 then
		if not e:IsCostChecked() then return false end
		return cg:CheckSubGroup(s.fselect,1,maxlv,tg)
	end
	-- 向己方玩家显示“请选择要除外的卡”的选择提示，用于选择效果②的COST。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local rg=cg:SelectSubGroup(tp,s.fselect,false,1,maxlv,tg)
	-- 将玩家选择的怪兽组rg以表侧表示除外，作为效果②发动所需的COST。
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
	e:SetLabel(rg:GetCount())
	-- 设置当前连锁的操作信息，声明本效果将把卡组中的1张卡加入手卡（从卡组检索），供后续处理和对方式点检测使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 定义效果②处理时的最终检索筛选条件：卡组中的龙族怪兽，卡名不是「钻头武装龙」，等级等于指定值lv（即之前的除外数量），并且可以加入手卡。
function s.thfilter2(c,lv)
	return not c:IsCode(id) and c:IsLevel(lv) and c:IsRace(RACE_DRAGON)
		and c:IsAbleToHand()
end
-- 效果②的检索处理：让玩家从卡组选择1张等级等于之前除外数量的符合条件的龙族怪兽加入手卡，并向对方展示选择。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向己方玩家显示“请选择要加入手牌的卡”的选择提示，用于选择检索目标。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让己方玩家从卡组选择1张等级等于e:GetLabel()（之前记录除外数量）的符合条件的龙族怪兽，返回所选的卡。
	local g=Duel.SelectMatchingCard(tp,s.thfilter2,tp,LOCATION_DECK,0,1,1,nil,e:GetLabel())
	if g:GetCount()>0 then
		-- 将检索选择的怪兽卡以效果原因加入持有者的手卡（此处加入当前玩家手卡）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将检索加入手卡的卡展示给对方玩家，以公开确认检索结果。
		Duel.ConfirmCards(1-tp,g)
	end
end
