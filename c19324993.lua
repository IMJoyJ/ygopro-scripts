--X・HERO ヘル・デバイサー
-- 效果：
-- 「英雄」怪兽2只
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡连接召唤的场合才能发动（这个效果发动的回合，自己不是「英雄」怪兽不能特殊召唤）。额外卡组1只「英雄」融合怪兽给对方观看，那只怪兽有卡名记述的最多2只融合素材怪兽从卡组加入手卡（同名卡最多1张）。
-- ②：这张卡所连接区的恶魔族怪兽的攻击力·守备力上升自身的等级×100。
function c19324993.initial_effect(c)
	-- 设置连接召唤手续：需要「英雄」怪兽2只
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0x8),2,2)
	c:EnableReviveLimit()
	-- ①：这张卡连接召唤的场合才能发动（这个效果发动的回合，自己不是「英雄」怪兽不能特殊召唤）。额外卡组1只「英雄」融合怪兽给对方观看，那只怪兽有卡名记述的最多2只融合素材怪兽从卡组加入手卡（同名卡最多1张）。
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
	-- 设置特殊召唤活动计数器，用于检测本回合是否特殊召唤过非「英雄」怪兽
	Duel.AddCustomActivityCounter(19324993,ACTIVITY_SPSUMMON,c19324993.counterfilter)
end
-- 特殊召唤活动计数器的过滤函数：判断特殊召唤的是否为表侧表示的「英雄」怪兽
function c19324993.counterfilter(c)
	return c:IsSetCard(0x8) and c:IsFaceup()
end
-- 效果发动条件：这张卡连接召唤成功
function c19324993.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 代价：检查本回合玩家是否特殊召唤过非「英雄」怪兽，并添加本回合只能特殊召唤「英雄」怪兽的誓约限制效果
function c19324993.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 限制条件检查：判断本回合自己是否特殊召唤过非「英雄」怪兽
	if chk==0 then return Duel.GetCustomActivityCount(19324993,tp,ACTIVITY_SPSUMMON)==0 end
	-- （这个效果发动的回合，自己不是「英雄」怪兽不能特殊召唤）。额外卡组1只「英雄」融合怪兽给对方观看，那只怪兽有卡名记述的最多2只融合素材怪兽从卡组加入手卡（同名卡最多1张）。②：这张卡所连接区的恶魔族怪兽的攻击力·守备力上升自身的等级×100。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c19324993.splimit)
	-- 对玩家注册该特殊召唤限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 特殊召唤限制：不能特殊召唤非「英雄」怪兽
function c19324993.splimit(e,c)
	return not c:IsSetCard(0x8)
end
-- 过滤额外卡组的卡：是「英雄」融合怪兽，且卡组中存在有其卡名记述的融合素材怪兽
function c19324993.ffilter(c,tp)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x8)
		-- 检查卡组是否存在有该融合怪兽卡名记述的融合素材怪兽
		and Duel.IsExistingMatchingCard(c19324993.thfilter,tp,LOCATION_DECK,0,1,nil,c)
end
-- 过滤检索的素材怪兽：是该融合怪兽有卡名记述的怪兽，且是怪兽卡并能加入手卡
function c19324993.thfilter(c,fc)
	-- 判断怪兽是否为融合怪兽有卡名记述的怪兽，且能加入手卡并是怪兽卡
	return aux.IsMaterialListCode(fc,c:GetCode()) and c:IsAbleToHand() and c:IsType(TYPE_MONSTER)
end
-- 效果目标：检查额外卡组中是否存在符合条件的「英雄」融合怪兽
function c19324993.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查额外卡组中是否存在可给对方观看且有卡名记述的素材存在于卡组的「英雄」融合怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c19324993.ffilter,tp,LOCATION_EXTRA,0,1,nil,tp) end
end
-- 效果运行：给对方确认额外卡组1只「英雄」融合怪兽，并将该怪兽有卡名记述的最多2只卡名不同的融合素材怪兽从卡组加入手卡
function c19324993.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择给对方确认的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 从额外卡组中选择1只符合条件的「英雄」融合怪兽
	local tc=Duel.SelectMatchingCard(tp,c19324993.ffilter,tp,LOCATION_EXTRA,0,1,1,nil,tp):GetFirst()
	if tc then
		-- 将选中的融合怪兽给对方确认
		Duel.ConfirmCards(1-tp,tc)
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 获取卡组中符合条件的该融合怪兽的融合素材怪兽
		local g=Duel.GetMatchingGroup(c19324993.thfilter,tp,LOCATION_DECK,0,nil,tc)
		-- 选择最多2只卡名互不相同的融合素材怪兽
		local sg=g:SelectSubGroup(tp,aux.dncheck,false,1,2)
		if sg and sg:GetCount()>0 then
			-- 将选中的怪兽加入手卡
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			-- 向对方玩家确认加入手卡的怪兽
			Duel.ConfirmCards(1-tp,sg)
		end
	end
end
-- 增值怪兽过滤：必须是此卡所连接区的恶魔族怪兽
function c19324993.atktg(e,c)
	return e:GetHandler():GetLinkedGroup():IsContains(c) and c:IsRace(RACE_FIEND)
end
-- 攻击力·守备力上升的值：自身的等级×100
function c19324993.atkval(e,c)
	return c:GetLevel()*100
end
