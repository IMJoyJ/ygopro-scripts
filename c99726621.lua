--鉄獣戦線 凶鳥のシュライグ
-- 效果：
-- 兽族·兽战士族·鸟兽族怪兽2只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤的场合或者自己场上有其他的兽族·兽战士族·鸟兽族怪兽特殊召唤的场合才能发动。场上1张卡除外。
-- ②：这张卡被送去墓地的场合才能发动。把持有自己的除外状态的兽族·兽战士族·鸟兽族怪兽数量以下的等级的1只兽族·兽战士族·鸟兽族怪兽从卡组加入手卡。
function c99726621.initial_effect(c)
	-- 为这张卡设置连接召唤手续：连接素材为兽族·兽战士族·鸟兽族怪兽2只以上（最多4只）。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST),2,4)
	c:EnableReviveLimit()
	-- ①：这张卡特殊召唤的场合或者自己场上有其他的兽族·兽战士族·鸟兽族怪兽特殊召唤的场合才能发动。场上1张卡除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(99726621,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCountLimit(1,99726621)
	e1:SetTarget(c99726621.rmtg)
	e1:SetOperation(c99726621.rmop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c99726621.rmcon)
	c:RegisterEffect(e2)
	-- ②：这张卡被送去墓地的场合才能发动。把持有自己的除外状态的兽族·兽战士族·鸟兽族怪兽数量以下的等级的1只兽族·兽战士族·鸟兽族怪兽从卡组加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(99726621,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,99726622)
	e3:SetTarget(c99726621.thtg)
	e3:SetOperation(c99726621.thop)
	c:RegisterEffect(e3)
end
-- ①效果的发动条件检查：获取双方场上所有可以除外的卡，确认至少存在1张，并登记“除外场上1张卡”的操作信息。
function c99726621.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取双方场上所有能被除外的卡，作为可选的除外对象。
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if chk==0 then return g:GetCount()>0 end
	-- 将本次连锁的操作信息设置为“除外”，目标为上述可选卡组，数量为1，用于后续效果互动检测。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- ①效果的处理：从双方场上选择1张可以除外的卡，将其表侧表示除外。
function c99726621.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家发送“请选择要除外的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从双方场上选择1张可以除外的卡。
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if g:GetCount()>0 then
		-- 显示被选中的卡作为选择对象的动画，并记录该卡被选择。
		Duel.HintSelection(g)
		-- 将选择的卡以表侧表示除外，除外原因为效果。
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
-- 判断一只怪兽是否为表侧表示、种族是否为兽族·兽战士族·鸟兽族，且控制者为己方。
function c99726621.cfilter(c,tp)
	return c:IsFaceup() and c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST) and c:IsControler(tp)
end
-- ①效果的另一触发条件：自己场上有其他符合条件的兽族·兽战士族·鸟兽族怪兽特殊召唤成功时（且特殊召唤的不是这张卡自身）才能发动。
function c99726621.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(c99726621.cfilter,1,nil,tp)
end
-- 判断除外区的卡是否为表侧表示且为兽族·兽战士族·鸟兽族怪兽，用于计算数量。
function c99726621.rfilter(c)
	return c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST) and c:IsFaceup()
end
-- 判断卡组的怪兽是否为兽族·兽战士族·鸟兽族、能否加入手牌，且等级≤lv（lv为除外区符合条件的怪兽数量）。
function c99726621.thfilter(c,lv)
	return c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST) and c:IsAbleToHand() and c:IsLevelBelow(lv)
end
-- ②效果的发动条件：计算自己除外区符合条件的怪兽数量ct；若ct>0且卡组存在等级≤ct的符合条件的怪兽，则可发动；并登记“从卡组加入手牌”的操作信息。
function c99726621.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 统计自己除外区的表侧表示兽族·兽战士族·鸟兽族怪兽数量。
		local ct=Duel.GetMatchingGroupCount(c99726621.rfilter,tp,LOCATION_REMOVED,0,nil)
		-- 确认除外区数量大于0且卡组中存在等级≤该数量的符合条件的检索目标。
		return ct>0 and Duel.IsExistingMatchingCard(c99726621.thfilter,tp,LOCATION_DECK,0,1,nil,ct)
	end
	-- 设置本次连锁操作为“从卡组加入手牌”（检索），目标数量1，所属玩家为自己，位置为卡组。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果的处理：重新统计除外区数量，从卡组选择1只等级≤该数量且符合条件的兽族·兽战士族·鸟兽族怪兽加入手牌，并让对方确认。
function c99726621.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次统计自己除外区符合条件的兽族·兽战士族·鸟兽族怪兽数量。
	local ct=Duel.GetMatchingGroupCount(c99726621.rfilter,tp,LOCATION_REMOVED,0,nil)
	if ct<=0 then return end
	-- 给玩家发送“请选择要加入手牌的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1只满足条件的兽族·兽战士族·鸟兽族怪兽（可加入手牌且等级≤ct）。
	local g=Duel.SelectMatchingCard(tp,c99726621.thfilter,tp,LOCATION_DECK,0,1,1,nil,ct)
	if g:GetCount()>0 then
		-- 将选择的卡加入其持有者的手牌，原因为效果。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方展示加入手牌的那张卡，以确认检索结果。
		Duel.ConfirmCards(1-tp,g)
	end
end
