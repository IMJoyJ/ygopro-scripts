--幻想の黒魔導師
-- 效果：
-- 7星怪兽×2
-- 这张卡也能在自己场上的6阶的魔法师族超量怪兽上面重叠来超量召唤。「幻想之黑魔导师」的②的效果1回合只能使用1次。
-- ①：1回合1次，把这张卡1个超量素材取除才能发动。从手卡·卡组把1只魔法师族的通常怪兽特殊召唤。
-- ②：魔法师族的通常怪兽的攻击宣言时，以对方场上1张卡为对象才能发动。那张卡除外。
function c96471335.initial_effect(c)
	aux.AddXyzProcedure(c,nil,7,2,c96471335.ovfilter,aux.Stringid(96471335,0))  --"是否要在自己场上的6阶的魔法师族超量怪兽上面重叠来超量召唤？"
	c:EnableReviveLimit()
	-- ①：1回合1次，把这张卡1个超量素材取除才能发动。从手卡·卡组把1只魔法师族的通常怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(96471335,1))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c96471335.cost)
	e1:SetTarget(c96471335.target)
	e1:SetOperation(c96471335.operation)
	c:RegisterEffect(e1)
	-- ②：魔法师族的通常怪兽的攻击宣言时，以对方场上1张卡为对象才能发动。那张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(96471335,2))  --"除外"
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,96471335)
	e2:SetCondition(c96471335.rmcon)
	e2:SetTarget(c96471335.rmtg)
	e2:SetOperation(c96471335.rmop)
	c:RegisterEffect(e2)
end
-- 过滤自己场上用于重叠超量召唤的怪兽（表侧表示、6阶、魔法师族）
function c96471335.ovfilter(c)
	return c:IsFaceup() and c:IsRank(6) and c:IsRace(RACE_SPELLCASTER)
end
-- 效果①的代价：取除这张卡的1个超量素材
function c96471335.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤手卡·卡组中可以特殊召唤的魔法师族通常怪兽
function c96471335.filter(c,e,tp)
	return c:IsType(TYPE_NORMAL) and c:IsRace(RACE_SPELLCASTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备：检查怪兽区域空位以及手卡·卡组是否存在可特召的怪兽
function c96471335.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可以特殊召唤怪兽的空余怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡或卡组中是否存在至少1只满足条件的魔法师族通常怪兽
		and Duel.IsExistingMatchingCard(c96471335.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，表示将从手卡或卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果①的效果处理：从手卡·卡组选择1只魔法师族通常怪兽特殊召唤
function c96471335.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否还有空余的怪兽区域，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡或卡组选择1只满足条件的魔法师族通常怪兽
	local g=Duel.SelectMatchingCard(tp,c96471335.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果②的发动条件：魔法师族的通常怪兽进行攻击宣言时
function c96471335.rmcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前进行攻击宣言的怪兽
	local tc=Duel.GetAttacker()
	return tc:IsType(TYPE_NORMAL) and tc:IsRace(RACE_SPELLCASTER)
end
-- 效果②的发动准备：选择对方场上1张卡作为对象，并设置除外操作信息
function c96471335.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	-- 检查对方场上是否存在可以被除外的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择对方场上1张可以被除外的卡作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置除外的操作信息，表示将除外选中的1张卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 效果②的效果处理：将作为对象的卡除外
function c96471335.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为效果对象的卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片以表侧表示除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
