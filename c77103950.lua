--壱世壊＝ペルレイノ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这个卡名的③的效果1回合只能使用1次。
-- ①：作为这张卡的发动时的效果处理，可以从卡组把1只「珠泪哀歌族」怪兽或者「维萨斯-斯塔弗罗斯特」加入手卡。
-- ②：自己场上的融合怪兽以及「珠泪哀歌族」怪兽的攻击力上升500。
-- ③：自己的场上·墓地的「珠泪哀歌族」怪兽回到卡组·额外卡组的场合，以场上1张卡为对象才能发动。那张卡破坏。
function c77103950.initial_effect(c)
	-- 记录本卡效果中记载了「维萨斯-斯塔弗罗斯特」的卡名
	aux.AddCodeList(c,56099748)
	-- ①：作为这张卡的发动时的效果处理，可以从卡组把1只「珠泪哀歌族」怪兽或者「维萨斯-斯塔弗罗斯特」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,77103950+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(c77103950.activate)
	c:RegisterEffect(e1)
	-- ②：自己场上的融合怪兽以及「珠泪哀歌族」怪兽的攻击力上升500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c77103950.atktg)
	e2:SetValue(500)
	c:RegisterEffect(e2)
	-- ③：自己的场上·墓地的「珠泪哀歌族」怪兽回到卡组·额外卡组的场合，以场上1张卡为对象才能发动。那张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(77103950,1))  --"场上卡破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,77103951)
	e3:SetCode(EVENT_TO_DECK)
	e3:SetCondition(c77103950.descon)
	e3:SetTarget(c77103950.destg)
	e3:SetOperation(c77103950.desop)
	c:RegisterEffect(e3)
end
-- 过滤卡组中属于「珠泪哀歌族」怪兽或卡名为「维萨斯-斯塔弗罗斯特」且能加入手牌的卡
function c77103950.filter(c)
	return ((c:IsSetCard(0x181) and c:IsType(TYPE_MONSTER)) or c:IsCode(56099748)) and c:IsAbleToHand()
end
-- 卡片发动时的效果处理：可以从卡组将1只符合条件的怪兽加入手牌
function c77103950.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己卡组中所有符合检索条件的卡片
	local g=Duel.GetMatchingGroup(c77103950.filter,tp,LOCATION_DECK,0,nil)
	-- 若卡组中存在符合条件的卡，则询问玩家是否发动检索效果
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(77103950,0)) then  --"是否从卡组把怪兽加入手卡？"
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选择的卡片加入手牌
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,sg)
	end
end
-- 攻击力上升效果的适用对象过滤：自己场上的融合怪兽或「珠泪哀歌族」怪兽
function c77103950.atktg(e,c)
	return c:IsType(TYPE_FUSION) or c:IsSetCard(0x181)
end
-- 过滤回到卡组的卡片：原本由自己控制的「珠泪哀歌族」怪兽，且原本在墓地或在场上表侧表示存在
function c77103950.cfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsSetCard(0x181) and c:IsType(TYPE_MONSTER)
		and (c:IsPreviousLocation(LOCATION_GRAVE)
			or (c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousSetCard(0x181)))
end
-- 破坏效果的发动条件：检查是否有符合条件的「珠泪哀歌族」怪兽回到了卡组
function c77103950.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c77103950.cfilter,1,nil,tp)
end
-- 破坏效果的靶向与合法性检测：选择场上1张卡作为破坏对象
function c77103950.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 效果发动时的合法性检测：检查场上是否存在可以作为对象的卡
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择场上1张卡作为效果的对象
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁信息，表明该效果的处理包含破坏场上1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏效果的实际处理：破坏选中的对象卡
function c77103950.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的那张卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 因效果将该对象卡破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
