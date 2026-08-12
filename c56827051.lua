--影霊衣の巫女 エリアル
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：1回合1次，把手卡的「影灵衣」卡任意数量给对方观看才能发动。这张卡的等级直到回合结束时上升或下降给人观看的数量的数值。
-- ②：这张卡被效果解放的场合才能发动。从卡组把仪式怪兽以外的1只「影灵衣」怪兽加入手卡。
function c56827051.initial_effect(c)
	-- ①：1回合1次，把手卡的「影灵衣」卡任意数量给对方观看才能发动。这张卡的等级直到回合结束时上升或下降给人观看的数量的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(56827051,0))  --"等级变更"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c56827051.lvcost)
	e1:SetOperation(c56827051.lvop)
	c:RegisterEffect(e1)
	-- ②：这张卡被效果解放的场合才能发动。从卡组把仪式怪兽以外的1只「影灵衣」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(56827051,1))  --"加入手卡"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_RELEASE)
	e2:SetCountLimit(1,56827051)
	e2:SetCondition(c56827051.thcon)
	e2:SetTarget(c56827051.thtg)
	e2:SetOperation(c56827051.thop)
	c:RegisterEffect(e2)
end
-- 过滤手卡中未公开的「影灵衣」卡片
function c56827051.cfilter(c)
	return c:IsSetCard(0xb4) and not c:IsPublic()
end
-- ①号效果的COST：展示手卡中任意数量的「影灵衣」卡，并记录展示的数量
function c56827051.lvcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在至少1张未公开的「影灵衣」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c56827051.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要给对方确认的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 让玩家选择手卡中任意数量（1到63张）未公开的「影灵衣」卡
	local g=Duel.SelectMatchingCard(tp,c56827051.cfilter,tp,LOCATION_HAND,0,1,63,nil)
	-- 给对方玩家确认选中的卡
	Duel.ConfirmCards(1-tp,g)
	-- 洗切自身手卡
	Duel.ShuffleHand(tp)
	e:SetLabel(g:GetCount())
end
-- ①号效果的处理：根据展示的卡片数量，选择让这张卡的等级上升或下降该数值
function c56827051.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	local ct=e:GetLabel()
	local sel=nil
	if c:IsLevel(1) then
		-- 若这张卡当前等级为1，则只能选择“等级上升”
		sel=Duel.SelectOption(tp,aux.Stringid(56827051,2))  --"等级上升"
	else
		-- 若这张卡当前等级大于1，则让玩家选择“等级上升”或“等级下降”
		sel=Duel.SelectOption(tp,aux.Stringid(56827051,2),aux.Stringid(56827051,3))  --"等级上升/等级下降"
	end
	if sel==1 then
		ct=ct*-1
	end
	-- 这张卡的等级直到回合结束时上升或下降给人观看的数量的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetValue(ct)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
end
-- ②号效果的发动条件：这张卡是被效果解放的场合
function c56827051.thcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT)~=0
end
-- 过滤卡组中仪式怪兽以外的「影灵衣」怪兽
function c56827051.filter(c)
	return c:IsSetCard(0xb4) and c:IsType(TYPE_MONSTER) and not c:IsType(TYPE_RITUAL) and c:IsAbleToHand()
end
-- ②号效果的靶向/发动准备：检查卡组中是否存在符合条件的怪兽，并设置检索的操作信息
function c56827051.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在仪式怪兽以外的「影灵衣」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c56827051.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置将卡组中的1张卡加入手卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②号效果的处理：从卡组将1只仪式怪兽以外的「影灵衣」怪兽加入手卡
function c56827051.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1只仪式怪兽以外的「影灵衣」怪兽
	local g=Duel.SelectMatchingCard(tp,c56827051.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
