--ジュークジョイント“Killer Tune”
-- 效果：
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：自己在通常召唤外加上只有1次，自己主要阶段可以把1只调整召唤。
-- ②：只要对方的场上或墓地有调整存在，自己场上的「杀手级调整曲响度战争」的攻击力上升3300。
-- ③：把自己场上1只调整解放才能发动。从卡组选1只「杀手级调整曲」怪兽加入手卡或特殊召唤。这个效果的发动后，直到回合结束时自己不是调整不能特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果，注册场地魔法卡的通用发动条件和三个效果
function s.initial_effect(c)
	-- 为该卡注册与“杀手级调整曲响度战争”相关的卡片代码，用于后续效果判断
	aux.AddCodeList(c,41069676)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己在通常召唤外加上只有1次，自己主要阶段可以把1只调整召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e2:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	-- 设置该效果仅对调整类型怪兽生效
	e2:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_TUNER))
	c:RegisterEffect(e2)
	-- ②：只要对方的场上或墓地有调整存在，自己场上的「杀手级调整曲响度战争」的攻击力上升3300。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	-- 设置该效果仅对「杀手级调整曲响度战争」生效
	e3:SetTarget(aux.TargetBoolFunction(Card.IsCode,41069676))
	e3:SetCondition(s.atkcon)
	e3:SetValue(3300)
	c:RegisterEffect(e3)
	-- ③：把自己场上1只调整解放才能发动。从卡组选1只「杀手级调整曲」怪兽加入手卡或特殊召唤。这个效果的发动后，直到回合结束时自己不是调整不能特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetCountLimit(1,id)
	e4:SetCost(s.spcost)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end
-- 定义用于判断场上是否存在满足条件的调整的过滤函数
function s.cfilter(c)
	return c:IsFaceupEx() and c:IsType(TYPE_TUNER)
end
-- 判断对方场上或墓地是否存在调整
function s.atkcon(e)
	-- 检查对方场上或墓地是否存在至少1只调整
	return Duel.IsExistingMatchingCard(s.cfilter,e:GetHandler():GetControler(),0,LOCATION_MZONE+LOCATION_GRAVE,1,nil)
end
-- 定义用于判断是否可以解放的调整的过滤函数
function s.cfilter2(c,e,tp)
	return c:IsType(TYPE_TUNER)
		-- 检查玩家手牌或场上是否存在满足条件的调整
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp,c)
end
-- 设置该效果的解放费用，要求玩家选择1只调整进行解放
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以支付解放费用
	if chk==0 then return Duel.CheckReleaseGroup(tp,s.cfilter2,1,nil,e,tp) end
	-- 让玩家从场上选择1只满足条件的调整进行解放
	local g=Duel.SelectReleaseGroup(tp,s.cfilter2,1,1,nil,e,tp)
	-- 执行调整的解放操作
	Duel.Release(g,REASON_COST)
end
-- 定义用于判断卡组中是否存在可加入手牌或特殊召唤的「杀手级调整曲」怪兽的过滤函数
function s.thfilter(c,e,tp,ec)
	if not (c:IsSetCard(0x1d5) and c:IsType(TYPE_MONSTER)) then return false end
	-- 计算玩家场上是否有可用的怪兽区域
	local res=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 计算玩家场上是否有可用的怪兽区域（考虑目标怪兽离开后的情况）
		or ec and Duel.GetMZoneCount(tp,ec)>0
	return c:IsAbleToHand() or (res and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- 设置该效果的发动条件，检查卡组中是否存在满足条件的怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked() or not e:IsCostChecked()
		-- 检查卡组中是否存在至少1只满足条件的怪兽
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp,nil) end
end
-- 执行该效果的处理流程，包括选择怪兽、决定加入手牌或特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要处理的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
	-- 从卡组中选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,nil)
	-- 获取玩家场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local tc=g:GetFirst()
	if tc then
		-- 判断是否选择将怪兽加入手牌，若不能特殊召唤或没有怪兽区域则优先加入手牌
		if tc:IsAbleToHand() and (not tc:IsCanBeSpecialSummoned(e,0,tp,false,false) or ft<=0 or Duel.SelectOption(tp,1190,1152)==0) then
			-- 将选中的怪兽加入手牌
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 向对方确认加入手牌的怪兽
			Duel.ConfirmCards(1-tp,tc)
		elseif tc:IsCanBeSpecialSummoned(e,0,tp,false,false) then
			-- 将选中的怪兽特殊召唤到场上
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 设置发动后直到回合结束时禁止非调整怪兽特殊召唤的效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册该禁止特殊召唤的效果
	Duel.RegisterEffect(e1,tp)
end
-- 定义禁止非调整怪兽特殊召唤的判断函数
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:GetOriginalType()&TYPE_TUNER==0
end
