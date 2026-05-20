--熾動する煉獄
-- 效果：
-- 这个卡名的②的效果在决斗中只能使用1次。
-- ①：把手卡1只「狱火机」怪兽或1张「炼狱」魔法·陷阱卡给对方观看才能发动。自己手卡全部丢弃。那之后，自己抽出丢弃的数量。
-- ②：自己场上的怪兽不存在的场合或者只有恶魔族怪兽的场合，把这个回合没有送去墓地的这张卡从墓地除外，以自己的除外状态的最多11只「狱火机」怪兽为对象才能发动（同名卡最多1张）。那些怪兽回到墓地。
local s,id,o=GetID()
-- 注册卡片效果：①发动时丢弃手卡并抽卡的效果，以及②在墓地除外自身使除外的「狱火机」怪兽回到墓地的效果。
function s.initial_effect(c)
	-- ①：把手卡1只「狱火机」怪兽或1张「炼狱」魔法·陷阱卡给对方观看才能发动。自己手卡全部丢弃。那之后，自己抽出丢弃的数量。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"丢弃&抽卡"
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果在决斗中只能使用1次。②：自己场上的怪兽不存在的场合或者只有恶魔族怪兽的场合，把这个回合没有送去墓地的这张卡从墓地除外，以自己的除外状态的最多11只「狱火机」怪兽为对象才能发动（同名卡最多1张）。那些怪兽回到墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"回到墓地"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+EFFECT_COUNT_CODE_DUEL)
	e2:SetCondition(s.tgcon)
	-- 设置发动代价为：把墓地的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
end
-- 过滤手卡中未给对方观看的「狱火机」怪兽或「炼狱」魔法·陷阱卡。
function s.costfilter(c)
	return (c:IsSetCard(0xbb) and c:IsType(TYPE_MONSTER)) or (c:IsSetCard(0xc5) and c:IsType(TYPE_SPELL+TYPE_TRAP)) and not c:IsPublic()
end
-- ①号效果的发动代价：展示手卡中1张满足条件的卡。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在除这张卡以外、可用于展示的「狱火机」怪兽或「炼狱」魔陷。
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 提示玩家选择要确认（展示）的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 让玩家选择手卡中1张满足条件的卡。
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选中的卡给对方玩家确认（观看）。
	Duel.ConfirmCards(1-tp,g)
	-- 重新洗切自身手卡。
	Duel.ShuffleHand(tp)
end
-- ①号效果的发动准备：检查手卡数量及是否能抽卡，并设置丢弃手卡和抽卡的操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取玩家当前的手卡数量。
		local h=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
		if e:GetHandler():IsLocation(LOCATION_HAND) then h=h-1 end
		-- 检查玩家手卡数量是否大于0，且玩家是否可以抽取等同于手卡数量的卡。
		return h>0 and Duel.IsPlayerCanDraw(tp,h)
	end
	-- 设置连锁信息：此效果包含丢弃手卡的操作。
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
	-- 设置连锁信息：此效果包含抽卡的操作。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ①号效果的处理：将自己手卡全部丢弃，那之后抽出丢弃数量的卡。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家当前的全部手卡。
	local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	-- 将全部手卡因效果丢弃送去墓地，并记录实际丢弃的卡片数量。
	local ct=Duel.SendtoGrave(g,REASON_EFFECT+REASON_DISCARD)
	if ct>0 then
		-- 中断当前效果处理，使后续的抽卡处理不与丢弃手卡同时进行（造成错时点）。
		Duel.BreakEffect()
		-- 玩家因效果抽取与丢弃数量相同的卡。
		Duel.Draw(tp,ct,REASON_EFFECT)
	end
end
-- 过滤非表侧表示或非恶魔族的怪兽（用于判断场上是否仅存在恶魔族怪兽）。
function s.cfilter(c)
	return c:IsFacedown() or not c:IsRace(RACE_FIEND)
end
-- ②号效果的发动条件：自己场上没有怪兽或只有恶魔族怪兽，且这张卡不是在当前回合送去墓地的。
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上的怪兽是否不存在，或者不存在非表侧表示且非恶魔族的怪兽（即只有恶魔族怪兽）。
	return (Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 or not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil))
		-- 检查这张卡是否不是在当前回合送去墓地（排除因回到墓地等特殊原因导致的回合数重置）。
		and (Duel.GetTurnCount()~=e:GetHandler():GetTurnID() or e:GetHandler():IsReason(REASON_RETURN))
end
-- 过滤自己除外状态的、表侧表示的、可以成为效果对象的「狱火机」怪兽。
function s.tgfilter(c,e)
	return c:IsSetCard(0xbb) and c:IsType(TYPE_MONSTER) and c:IsCanBeEffectTarget(e) and c:IsFaceup()
end
-- ②号效果的发动准备：选择自己除外状态的最多11只「狱火机」怪兽（同名卡最多1张）作为效果对象。
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取自己除外状态的所有满足条件的「狱火机」怪兽。
	local tg=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_REMOVED,0,nil,e)
	if chk==0 then return #tg>0 end
	-- 提示玩家选择要操作的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 设置额外检查函数，确保后续选择的卡片组中不包含同名卡。
	aux.GCheckAdditional=aux.dncheck
	-- 让玩家从满足条件的卡中选择1到11张卡，且卡名互不相同。
	local g=tg:SelectSubGroup(tp,aux.TRUE,false,1,11)
	-- 重置额外检查函数，避免影响后续的选择逻辑。
	aux.GCheckAdditional=nil
	-- 将选中的卡片组设为当前效果的对象。
	Duel.SetTargetCard(g)
	-- 设置连锁信息：此效果包含将选中的卡送去墓地（回到墓地）的操作。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,g:GetCount(),0,0)
end
-- ②号效果的处理：使作为对象的除外状态的「狱火机」怪兽回到墓地。
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍对该效果有效的对象卡片。
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()>0 then
		-- 将这些对象怪兽送回墓地。
		Duel.SendtoGrave(tg,REASON_EFFECT+REASON_RETURN)
	end
end
