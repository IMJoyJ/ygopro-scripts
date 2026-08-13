--銀河眼の時源竜
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方回合，场上有龙族超量怪兽存在的场合才能发动。这张卡从手卡往自己或对方的场上特殊召唤。
-- ②：这张卡召唤·特殊召唤的场合发动。这张卡的原本持有者从自身卡组把1张「时空」魔法·陷阱卡加入手卡。
-- ③：自己或对方的龙族超量怪兽的攻击宣言时发动。把场上的这张卡作为那只怪兽的超量素材。
local s,id,o=GetID()
-- 为银河眼时源龙注册全部效果：①手牌诱发的即时效果，可从手卡特殊召唤到自己或对方场上；②召唤成功时检索「时空」魔法·陷阱卡（同时用复制效果处理特殊召唤成功时）；③攻击宣言时作为龙族超量怪兽的超量素材。
function s.initial_effect(c)
	-- ①：自己·对方回合，场上有龙族超量怪兽存在的场合才能发动。这张卡从手卡往自己或对方的场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤的场合发动。这张卡的原本持有者从自身卡组把1张「时空」魔法·陷阱卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ③：自己或对方的龙族超量怪兽的攻击宣言时发动。把场上的这张卡作为那只怪兽的超量素材。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))  --"变成超量素材"
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_ATTACK_ANNOUNCE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTarget(s.mttg)
	e4:SetOperation(s.mtop)
	c:RegisterEffect(e4)
end
-- 定义过滤函数，用于筛选场上表侧表示的龙族超量怪兽。
function s.cfilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsType(TYPE_XYZ) and c:IsFaceup()
end
-- ①效果的发动条件：检查场上是否存在至少1只表侧表示的龙族超量怪兽。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 调用Duel.IsExistingMatchingCard检查以发动方视角看双方主要怪兽区是否存在至少1只满足s.cfilter条件的怪兽。
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- ①效果的发动目标合法性判定：确认这张卡能特殊召唤到自己或对方场上（任一方有可用怪兽区且满足特殊召唤条件）。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判定自己场上是否有可用怪兽区域且这张卡可以特殊召唤到自己场上。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 判定对方场上是否有可用怪兽区域且这张卡可以表侧表示特殊召唤到对方场上。
		or Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp) end
	-- 设置操作信息：本次连锁将进行特殊召唤，对象为这张卡，供需要检测特殊召唤的卡（如星尘龙）参考。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理：检查卡片关联及召唤合法性，让发动者选择特殊召唤到自己或对方场上；若双方均无空位则这张卡以规则原因送去墓地。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or (not c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)) then return end
	-- 计算能否特殊召唤到自己场上，作为选项“自己场上”的可用性。
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	-- 计算能否特殊召唤到对方场上，作为选项“对方场上”的可用性。
	local b2=Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
	-- 弹出选项，让当前回合玩家选择将这张卡特殊召唤到哪一方场上。
	local toplayer=aux.SelectFromOptions(tp,
		{b1,aux.Stringid(id,3),tp},  --"往自己场上特殊召唤"
		{b2,aux.Stringid(id,4),1-tp})  --"往对方场上特殊召唤"
	if toplayer~=nil then
		-- 按玩家的选择将这张卡表侧表示特殊召唤到对应玩家的主要怪兽区。
		Duel.SpecialSummon(c,0,tp,toplayer,false,false,POS_FACEUP)
	else
		-- 若双方场上均没有可用的主要怪兽区域，则特殊召唤无法进行。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 and Duel.GetLocationCount(1-tp,LOCATION_MZONE)<=0 then
			-- 在无法特殊召唤且双方均无空位时，将以规则原因把这张卡送去墓地。
			Duel.SendtoGrave(c,REASON_RULE)
		end
	end
end
-- 定义检索过滤条件：筛选卡名属于「时空」系列的魔法·陷阱卡，且可以被加入手卡。
function s.thfilter(c)
	return c:IsSetCard(0x1b4) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- ②效果发动时无对象，只设置操作信息；确认后从原本持有者卡组检索「时空」魔法·陷阱卡。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local hp=e:GetHandler():GetOwner()
	if chk==0 then return true end
	-- 设置操作信息：从原本持有者卡组将1张「时空」魔法·陷阱卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,hp,LOCATION_DECK)
end
-- ②效果处理：由原本持有者从自身卡组选择1张符合条件的「时空」魔法·陷阱卡加入手卡，并向对方确认。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local hp=e:GetHandler():GetOwner()
	-- 提示选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 由原本持有者（hp）从自身卡组筛选并选择1张符合条件的「时空」魔法·陷阱卡。
	local g=Duel.SelectMatchingCard(hp,s.thfilter,hp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选出的卡加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示这张加入手卡的卡，以确认检索内容。
		Duel.ConfirmCards(1-hp,g)
	end
end
-- ③效果发动条件：攻击宣言的怪兽为龙族超量怪兽且在场上。
function s.mttg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取攻击宣言的怪兽。
	local at=Duel.GetAttacker()
	if chk==0 then return at:IsType(TYPE_XYZ) and at:IsOnField() and at:IsRace(RACE_DRAGON) end
end
-- ③效果处理：若这张卡仍与效果关联且可作为超量素材，且攻击怪兽不免疫此效果，则将这张卡叠放在攻击怪兽下方作为超量素材。
function s.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取攻击宣言的怪兽。
	local at=Duel.GetAttacker()
	if c:IsRelateToEffect(e) and c:IsCanOverlay()
		and at:IsRelateToBattle() and not at:IsImmuneToEffect(e) then
		-- 将这张卡作为攻击怪兽的超量素材叠放。
		Duel.Overlay(at,Group.FromCards(c))
	end
end
