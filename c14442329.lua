--ジュークジョイント“Killer Tune”
-- 效果：
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：自己在通常召唤外加上只有1次，自己主要阶段可以把1只调整召唤。
-- ②：只要对方的场上或墓地有调整存在，自己场上的「杀手级调整曲响度战争」的攻击力上升3300。
-- ③：把自己场上1只调整解放才能发动。从卡组选1只「杀手级调整曲」怪兽加入手卡或特殊召唤。这个效果的发动后，直到回合结束时自己不是调整不能特殊召唤。
local s,id,o=GetID()
-- 注册此卡作为魔法卡可以发动，并依次注册效果：①增加1次调整怪兽的通常召唤；②己方「杀手级调整曲响度战争」攻击力上升3300；③解放调整怪兽从卡组检索或特召「杀手级调整曲」怪兽。
function s.initial_effect(c)
	-- 记录这张卡上记载的卡名41069676（杀手级调整曲响度战争），用于相关效果检索或判定。
	aux.AddCodeList(c,41069676)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己在通常召唤外加上只有1次，自己主要阶段可以把1只调整召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"使用「点唱机酒吧“杀手级调整曲”」的效果召唤"
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e2:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	-- 将额外增加通常召唤的对象限定为调整怪兽。
	e2:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_TUNER))
	c:RegisterEffect(e2)
	-- ②：只要对方的场上或墓地有调整存在，自己场上的「杀手级调整曲响度战争」的攻击力上升3300。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	-- 指定攻击力上升效果只对卡号为41069676的「杀手级调整曲响度战争」适用。
	e3:SetTarget(aux.TargetBoolFunction(Card.IsCode,41069676))
	e3:SetCondition(s.atkcon)
	e3:SetValue(3300)
	c:RegisterEffect(e3)
	-- 这个卡名的③的效果1回合只能使用1次。③：把自己场上1只调整解放才能发动。从卡组选1只「杀手级调整曲」怪兽加入手卡或特殊召唤。这个效果的发动后，直到回合结束时自己不是调整不能特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))  --"检索效果"
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
-- 定义过滤函数：用于判断一张卡是否为表侧表示的调整怪兽。
function s.cfilter(c)
	return c:IsFaceupEx() and c:IsType(TYPE_TUNER)
end
-- ②效果的适用条件：检查对方场上或墓地是否存在表侧表示的调整怪兽。
function s.atkcon(e)
	-- 在对方的怪兽区域或墓地检索是否存在至少1只表侧表示的调整怪兽，作为攻击力上升的适用条件。
	return Duel.IsExistingMatchingCard(s.cfilter,e:GetHandler():GetControler(),0,LOCATION_MZONE+LOCATION_GRAVE,1,nil)
end
-- 定义解放候选的过滤条件：这张卡是调整怪兽，并且自己的卡组中存在可以加入手卡或特殊召唤的「杀手级调整曲」怪兽。
function s.cfilter2(c,e,tp)
	return c:IsType(TYPE_TUNER)
		-- 确认卡组中存在至少1只满足s.thfilter的「杀手级调整曲」怪兽，作为可以选择此调整解放的依据。
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp,c)
end
-- ③效果的发动代价处理：检查并选择自己场上1只调整怪兽解放，同时要求卡组中有可检索的目标。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在cost检查阶段，确认自己场上是否存在1只可作为解放代价的调整怪兽（且卡组有对应检索目标）。
	if chk==0 then return Duel.CheckReleaseGroup(tp,s.cfilter2,1,nil,e,tp) end
	-- 从自己场上选择1只满足条件的调整怪兽作为解放代价。
	local g=Duel.SelectReleaseGroup(tp,s.cfilter2,1,1,nil,e,tp)
	-- 将选择的调整怪兽解放，作为效果发动的cost。
	Duel.Release(g,REASON_COST)
end
-- 定义卡组检索目标的条件：必须是「杀手级调整曲」怪兽，且满足可加入手卡，或能特殊召唤（同时考虑解放后是否腾出怪兽区）。
function s.thfilter(c,e,tp,ec)
	if not (c:IsSetCard(0x1d5) and c:IsType(TYPE_MONSTER)) then return false end
	-- 检查自己场上当前是否有可用的怪兽区空位，用于判断能否特殊召唤。
	local res=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 若解放的怪兽离场后会空出怪兽区，也视为有可用怪兽区，从而支持特殊召唤选项。
		or ec and Duel.GetMZoneCount(tp,ec)>0
	return c:IsAbleToHand() or (res and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- ③效果的发动条件：检查卡组中是否存在符合条件的「杀手级调整曲」怪兽；在cost已确定的情况下直接满足条件。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked() or not e:IsCostChecked()
		-- 确认卡组中存在至少1只可加入手卡或特殊召唤的「杀手级调整曲」怪兽。
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp,nil) end
end
-- 执行③效果：从卡组选择1只「杀手级调整曲」怪兽，根据情况加入手卡或特殊召唤，并给自身附加直到回合结束只能特殊召唤调整怪兽的自肃效果。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家显示选择框提示“请选择要操作的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从卡组中选择1只满足s.thfilter的「杀手级调整曲」怪兽作为处理对象。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,nil)
	-- 获取自己场上当前可用的怪兽区域数量，用于后续决定是否选择特殊召唤。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local tc=g:GetFirst()
	if tc then
		-- 当选择的怪兽可以加入手卡，且（不能特殊召唤、没有怪兽区空位、或玩家选择加入手卡）时，进入加入手卡的分支；否则若可以特殊召唤则进入特召分支。
		if tc:IsAbleToHand() and (not tc:IsCanBeSpecialSummoned(e,0,tp,false,false) or ft<=0 or Duel.SelectOption(tp,1190,1152)==0) then
			-- 将选择的怪兽加入持有者的手卡。
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 向对方玩家展示刚刚加入手卡的卡片。
			Duel.ConfirmCards(1-tp,tc)
		elseif tc:IsCanBeSpecialSummoned(e,0,tp,false,false) then
			-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 这个效果的发动后，直到回合结束时自己不是调整不能特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将以玩家为对象的特殊召唤限制效果注册到场上，持续到回合结束。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃限制判定：若怪兽的原始类型不是调整，则不能特殊召唤，即只能特殊召唤调整怪兽。
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:GetOriginalType()&TYPE_TUNER==0
end
