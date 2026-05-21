--影霊衣の舞巫女 エミリア
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己的场上或墓地有战士族「影灵衣」怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡召唤·特殊召唤的场合才能发动。从卡组把1只「影灵衣」仪式怪兽或1张「影灵衣」魔法卡加入手卡。
-- ③：「影灵衣」仪式怪兽1只仪式召唤的场合，可以由自己场上的这1张卡作为仪式召唤需要的数值的解放使用。
local s,id,o=GetID()
-- 初始化函数，用于注册卡片的所有效果
function s.initial_effect(c)
	-- ①：自己的场上或墓地有战士族「影灵衣」怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤的场合才能发动。从卡组把1只「影灵衣」仪式怪兽或1张「影灵衣」魔法卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"检索"
	e2:SetCategory(CATEGORY_SEARCH|CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,id+o)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ③：「影灵衣」仪式怪兽1只仪式召唤的场合，可以由自己场上的这1张卡作为仪式召唤需要的数值的解放使用。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_RITUAL_LEVEL)
	e4:SetValue(s.rlevel)
	c:RegisterEffect(e4)
end
-- 过滤条件：场上表侧表示或墓地存在的战士族「影灵衣」怪兽
function s.cfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0xb4) and c:IsRace(RACE_WARRIOR)
end
-- 效果①的发动条件：检查场上或墓地是否存在战士族「影灵衣」怪兽
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上或墓地是否存在至少1张满足过滤条件的卡
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil)
end
-- 效果①的发动准备与合法性检查：检查怪兽区域是否有空位且自身能否特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查自己怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁中的操作信息：将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的效果处理：若自身仍在手卡，则将自身特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己的怪兽区域
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤条件：卡组中的「影灵衣」仪式怪兽或「影灵衣」魔法卡
function s.thfilter(c)
	return c:IsSetCard(0xb4) and c:IsAbleToHand()
		and (c:IsAllTypes(TYPE_MONSTER+TYPE_RITUAL) or c:IsType(TYPE_SPELL))
end
-- 效果②的发动准备与合法性检查：检查卡组中是否存在可检索的卡
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查卡组中是否存在满足过滤条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁中的操作信息：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②的效果处理：从卡组选择1张满足条件的卡加入手卡并给对方确认
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡片加入玩家手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果③的数值计算：作为「影灵衣」仪式召唤的祭品时，可作为仪式召唤需要的数值（等级）解放
function s.rlevel(e,c)
	local ec=e:GetHandler()
	-- 获取该怪兽在系统安全阈值内的等级数值
	local lv=aux.GetCappedLevel(ec)
	if not ec:IsLocation(LOCATION_MZONE) then return lv end
	if c:IsSetCard(0xb4) then
		local clv=c:GetLevel()
		return (lv<<16)+clv
	else return lv end
end
