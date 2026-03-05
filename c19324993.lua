--X・HERO ヘル・デバイサー
-- 效果：
-- 「英雄」怪兽2只
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡连接召唤的场合才能发动（这个效果发动的回合，自己不是「英雄」怪兽不能特殊召唤）。额外卡组1只「英雄」融合怪兽给对方观看，那只怪兽有卡名记述的最多2只融合素材怪兽从卡组加入手卡（同名卡最多1张）。
-- ②：这张卡所连接区的恶魔族怪兽的攻击力·守备力上升自身的等级×100。
function c19324993.initial_effect(c)
	-- 为卡片添加连接召唤手续，要求使用至少2张且至多2张满足过滤条件的怪兽作为连接素材，过滤条件为是否为「英雄」卡。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0x8),2,2)
	c:EnableReviveLimit()
	-- ①：这张卡连接召唤的场合才能发动（这个效果发动的回合，自己不是「英雄」怪兽不能特殊召唤）。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19324993,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,19324993)
	e1:SetCondition(c19324993.thcon)
	e1:SetCost(c19324993.thcost)
	e1:SetTarget(c19324993.thtg)
	e1:SetOperation(c19324993.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡所连接区的恶魔族怪兽的攻击力·守备力上升自身的等级×100。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(c19324993.atktg)
	e2:SetValue(c19324993.atkval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	-- 设置一个计数器，用于记录玩家在该回合中特殊召唤的「英雄」怪兽数量，防止超过1次。
	Duel.AddCustomActivityCounter(19324993,ACTIVITY_SPSUMMON,c19324993.counterfilter)
end
-- 计数器的过滤函数，判断卡片是否为「英雄」卡。
function c19324993.counterfilter(c)
	return c:IsSetCard(0x8)
end
-- 效果发动的条件，判断该卡是否为连接召唤成功。
function c19324993.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 效果发动的费用，检查该回合是否已使用过此效果，若未使用则设置一个回合结束时重置的不能特殊召唤效果。
function c19324993.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查该回合是否已使用过此效果，若未使用则返回true。
	if chk==0 then return Duel.GetCustomActivityCount(19324993,tp,ACTIVITY_SPSUMMON)==0 end
	-- 创建一个影响对方玩家的永续效果，禁止其特殊召唤非「英雄」怪兽。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c19324993.splimit)
	-- 将该效果注册给指定玩家。
	Duel.RegisterEffect(e1,tp)
end
-- 限制特殊召唤的过滤函数，禁止召唤非「英雄」卡。
function c19324993.splimit(e,c)
	return not c:IsSetCard(0x8)
end
-- 融合怪兽的过滤函数，筛选出额外卡组中满足类型为融合、种族为「英雄」且卡组中存在其融合素材的怪兽。
function c19324993.ffilter(c,tp)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x8)
		-- 检查卡组中是否存在该融合怪兽的融合素材。
		and Duel.IsExistingMatchingCard(c19324993.thfilter,tp,LOCATION_DECK,0,1,nil,c)
end
-- 检索卡的过滤函数，判断是否为融合素材且可加入手牌。
function c19324993.thfilter(c,fc)
	-- 判断该卡是否为融合素材且可加入手牌。
	return aux.IsMaterialListCode(fc,c:GetCode()) and c:IsAbleToHand() and c:IsType(TYPE_MONSTER)
end
-- 效果的发动目标，检查额外卡组中是否存在满足条件的融合怪兽。
function c19324993.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查额外卡组中是否存在满足条件的融合怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c19324993.ffilter,tp,LOCATION_EXTRA,0,1,nil,tp) end
end
-- 效果的发动处理，选择融合怪兽并展示给对方，再选择最多2张其融合素材加入手牌。
function c19324993.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择一张融合怪兽给对方确认。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 从额外卡组中选择一张满足条件的融合怪兽。
	local tc=Duel.SelectMatchingCard(tp,c19324993.ffilter,tp,LOCATION_EXTRA,0,1,1,nil,tp):GetFirst()
	if tc then
		-- 将该融合怪兽展示给对方玩家。
		Duel.ConfirmCards(1-tp,tc)
		-- 提示玩家选择要加入手牌的融合素材。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 获取满足条件的融合素材组。
		local g=Duel.GetMatchingGroup(c19324993.thfilter,tp,LOCATION_DECK,0,nil,tc)
		-- 从融合素材组中选择最多2张卡名不同的卡。
		local sg=g:SelectSubGroup(tp,aux.dncheck,false,1,2)
		if sg and sg:GetCount()>0 then
			-- 将选中的融合素材加入手牌。
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			-- 将选中的融合素材展示给对方玩家。
			Duel.ConfirmCards(1-tp,sg)
		end
	end
end
-- 判断目标怪兽是否为连接区的恶魔族怪兽。
function c19324993.atktg(e,c)
	return e:GetHandler():GetLinkedGroup():IsContains(c) and c:IsRace(RACE_FIEND)
end
-- 计算连接区恶魔族怪兽的攻击力提升值，为自身等级乘以100。
function c19324993.atkval(e,c)
	return c:GetLevel()*100
end
