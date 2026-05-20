--堕天使グルガルタ
-- 效果：
-- 自己对「堕天使 骼骼他」1回合只能有1次特殊召唤，那个②的效果1回合只能使用1次。
-- ①：这张卡特殊召唤的场合才能发动。在自己场上把2只「堕天使衍生物」（天使族·暗·6星·攻/守0）特殊召唤。这个效果的发动后，直到回合结束时自己不是天使族怪兽不能特殊召唤。
-- ②：这张卡被送去墓地的场合才能发动。从卡组把1张「堕天使 骼骼他」以外的「堕天使」卡或「禁忌的」速攻魔法卡加入手卡。
local s,id,o=GetID()
-- 初始化卡片效果，设置1回合只能特殊召唤1次，并注册①②效果
function s.initial_effect(c)
	c:SetSPSummonOnce(id)
	-- ①：这张卡特殊召唤的场合才能发动。在自己场上把2只「堕天使衍生物」（天使族·暗·6星·攻/守0）特殊召唤。这个效果的发动后，直到回合结束时自己不是天使族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_TOKEN+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡被送去墓地的场合才能发动。从卡组把1张「堕天使 骼骼他」以外的「堕天使」卡或「禁忌的」速攻魔法卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- ①效果（特殊召唤衍生物）的发动准备与条件检查函数
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查自己场上的怪兽区域是否有2个以上的空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检查玩家是否能够特殊召唤指定的衍生物怪兽
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0xef,TYPES_TOKEN_MONSTER,0,0,6,RACE_FAIRY,ATTRIBUTE_DARK) end
	-- 设置产生2只衍生物的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
	-- 设置特殊召唤2只怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,0,0)
end
-- ①效果（特殊召唤衍生物）的效果处理函数
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>1 and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 在效果处理时，再次检查是否能够特殊召唤指定的衍生物怪兽
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0xef,TYPES_TOKEN_MONSTER,0,0,6,RACE_FAIRY,ATTRIBUTE_DARK) then
		for i=1,2 do
			-- 在系统内创建指定的衍生物卡片
			local token=Duel.CreateToken(tp,id+o)
			-- 将创建的衍生物以表侧表示逐步特殊召唤到场上
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		end
		-- 完成这一组怪兽的特殊召唤程序
		Duel.SpecialSummonComplete()
	end
	-- 这个效果的发动后，直到回合结束时自己不是天使族怪兽不能特殊召唤。②：这张卡被送去墓地的场合才能发动。从卡组把1张「堕天使 骼骼他」以外的「堕天使」卡或「禁忌的」速攻魔法卡加入手卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 向玩家注册直到回合结束时不能特殊召唤天使族以外怪兽的限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制只能特殊召唤天使族怪兽的过滤函数
function s.splimit(e,c)
	return not c:IsRace(RACE_FAIRY)
end
-- 过滤卡组中「堕天使 骼骼他」以外的「堕天使」卡或「禁忌的」速攻魔法卡且能加入手牌的过滤函数
function s.thfilter(c)
	return (c:IsSetCard(0xef) and not c:IsCode(id)
		or c:IsSetCard(0x11d) and c:IsAllTypes(TYPE_QUICKPLAY+TYPE_SPELL))
		and c:IsAbleToHand()
end
-- ②效果（检索卡片）的发动准备与条件检查函数
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足检索条件的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置将1张卡从卡组加入手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果（检索卡片）的效果处理函数
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足过滤条件的卡片
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡片加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡片进行确认
		Duel.ConfirmCards(1-tp,g)
	end
end
