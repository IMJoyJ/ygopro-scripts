--U.A.ストロングブロッカー
-- 效果：
-- 「超级运动员 强壮阻挡员」的①的方法的特殊召唤1回合只能有1次。
-- ①：这张卡可以让「超级运动员 强壮阻挡员」以外的自己场上1只「超级运动员」怪兽回到手卡，从手卡特殊召唤。
-- ②：1回合1次，对方对怪兽的特殊召唤成功时才能发动。那些怪兽的表示形式变更，那个效果无效。
function c34614289.initial_effect(c)
	-- 「超级运动员 强壮阻挡员」的①的方法的特殊召唤1回合只能有1次。①：这张卡可以让「超级运动员 强壮阻挡员」以外的自己场上1只「超级运动员」怪兽回到手卡，从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,34614289+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c34614289.spcon)
	e1:SetTarget(c34614289.sptg)
	e1:SetOperation(c34614289.spop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，对方对怪兽的特殊召唤成功时才能发动。那些怪兽的表示形式变更，那个效果无效。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DISABLE+CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c34614289.postg)
	e2:SetOperation(c34614289.posop)
	c:RegisterEffect(e2)
end
-- 过滤可作为特殊召唤代价的怪兽：需为表侧表示、属于「超级运动员」系列、卡名不是「超级运动员 强壮阻挡员」、可以作为代价返回手牌，并且该卡返回手牌后我方场上仍有空余的主要怪兽区。
function c34614289.spfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0xb2) and not c:IsCode(34614289) and c:IsAbleToHandAsCost()
		-- 额外判定：该怪兽返回手牌后，我方场上仍有可用的怪兽区（EFFECT_SPSUMMON_PROC 要求特殊召唤时必须有空位），这样这张卡才能从手牌特殊召唤。
		and Duel.GetMZoneCount(tp,c)>0
end
-- 特殊召唤手续的发动条件：当尝试用这个方式特殊召唤这张卡时，需确认自己场上存在至少1只满足 spfilter 条件的「超级运动员」怪兽；若 c 为 nil（规则询问是否适用），则直接允许。
function c34614289.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 使用 Duel.IsExistingMatchingCard 检查以当前控制者 tp 看来的自己怪兽区（LOCATION_MZONE）是否存在至少1张满足 spfilter 的卡，用于确认特殊召唤手续所需的返回手牌代价是否可行。
	return Duel.IsExistingMatchingCard(c34614289.spfilter,tp,LOCATION_MZONE,0,1,nil,tp)
end
-- 特殊召唤手续的对象选择：获取所有可作为代价的「超级运动员」怪兽，让玩家选择其中1张返回手牌；选中后存入效果标签供后续操作使用，并返回 true 表示可以继续特殊召唤，否则返回 false。
function c34614289.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取当前玩家场上所有满足 spfilter（可作为返回手牌代价）的「超级运动员」怪兽，构成候选集合供玩家选择。
	local g=Duel.GetMatchingGroup(c34614289.spfilter,tp,LOCATION_MZONE,0,nil,tp)
	-- 显示选择提示：让玩家选择要返回手牌的卡片，提示文字为系统预设的“请选择要返回手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤手续的处理阶段：把之前选定的怪兽返回持有者手牌，此操作作为特殊召唤的代价；随后由 EFFECT_SPSUMMON_PROC 规则将这张卡从手牌特殊召唤。
function c34614289.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选定的怪兽返回其持有者的手牌，原因标记为特殊召唤（REASON_SPSUMMON），作为本次特殊召唤的代价。
	Duel.SendtoHand(g,nil,REASON_SPSUMMON)
end
-- ②效果的怪兽过滤器：判断对象怪兽是否为对方玩家（sp）所特殊召唤，并且当前表示形式可以被变更。
function c34614289.filter(c,sp)
	return c:IsSummonPlayer(sp) and c:IsCanChangePosition()
end
-- ②效果的发动条件和对象设定：在对方特殊召唤成功时（eg 为特殊召唤成功的怪兽组），若其中存在至少1只由对方特殊召唤且可变更表示形式的怪兽，则将这些怪兽全部选为对象，并登记本连锁将进行表示形式变更与效果无效的操作信息。
function c34614289.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c34614289.filter,1,nil,1-tp) end
	local g=eg:Filter(c34614289.filter,nil,1-tp)
	-- 将选中的那些对方特殊召唤的怪兽设为当前连锁的对象，与效果建立联系，以供效果处理时获取。
	Duel.SetTargetCard(g)
	-- 登记操作信息：本连锁将对 g 中这些怪兽进行表示形式变更（CATEGORY_POSITION），数量为 g 的怪兽数。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
	-- 登记操作信息：本连锁还将对这些怪兽进行效果无效（CATEGORY_DISABLE），数量为 g 的怪兽数。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,g:GetCount(),0,0)
end
-- ②效果处理：先取得连锁对象中仍与该效果相关的怪兽，将它们的表示形式反转（攻击表示→表侧守备，守备表示→表侧攻击）；然后对实际变更成功的每只怪兽，无效其相关连锁，并赋予其“怪兽效果无效”和“已发动效果无效”的持续效果，直到其离场/变里侧等重置条件发生。
function c34614289.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁开始时设定的对象卡组，并过滤出仍与本次效果有关联的卡（即没有因离场等原因失去联系的对象），后续只对这些卡处理。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 变更表示形式：根据怪兽原表示形式进行反转——原本攻击表示/里侧攻击表示变为表侧守备表示，原本守备表示/里侧守备表示变为表侧攻击表示。
	Duel.ChangePosition(g,POS_FACEUP_DEFENSE,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	-- 获取上一步 ChangePosition 实际改变了表示形式的怪兽集合，后续效果无效处理只针对这些实际变更成功的怪兽。
	local og=Duel.GetOperatedGroup()
	local tc=og:GetFirst()
	while tc do
		-- 使与该怪兽相关的连锁（如该怪兽特殊召唤成功时发动的效果连锁）无效化，实现“那个效果无效”中针对已发动连锁的无效部分；RESET_TURN_SET 表示该无效状态会在变里侧或阶段/回合重置时解除。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 那个效果无效。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 那个效果无效。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		tc=og:GetNext()
	end
end
