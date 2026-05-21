--星遺物の守護竜
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：这张卡的发动时，可以以自己墓地1只4星以下的龙族怪兽为对象。那个场合，那只怪兽加入手卡或特殊召唤。
-- ②：1回合1次，以自己场上1只龙族怪兽为对象才能发动。那只自己怪兽的位置向其他的自己的主要怪兽区域移动。
function c87571563.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：这张卡的发动时，可以以自己墓地1只4星以下的龙族怪兽为对象。那个场合，那只怪兽加入手卡或特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,87571563+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c87571563.target)
	c:RegisterEffect(e1)
	-- ②：1回合1次，以自己场上1只龙族怪兽为对象才能发动。那只自己怪兽的位置向其他的自己的主要怪兽区域移动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(87571563,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c87571563.seqtg)
	e2:SetOperation(c87571563.seqop)
	c:RegisterEffect(e2)
end
-- 定义用于过滤自己墓地中等级4以下、可以加入手卡或特殊召唤的龙族怪兽的过滤函数
function c87571563.spfilter(c,e,tp)
	-- 检查卡片是否为4星以下的龙族怪兽，且满足“能加入手卡”或“场上有空位且能特殊召唤”的条件之一
	return c:IsLevelBelow(4) and c:IsRace(RACE_DRAGON) and (c:IsAbleToHand() or (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
-- 魔法卡发动时的效果处理函数，判断是否在发动时选择墓地的龙族怪兽作为对象
function c87571563.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c87571563.spfilter(chkc,e,tp) end
	if chk==0 then return true end
	-- 检查自己墓地是否存在满足条件的龙族怪兽
	if Duel.IsExistingTarget(c87571563.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 询问玩家是否在发动这张卡时，选择墓地的怪兽作为对象
		and Duel.SelectYesNo(tp,aux.Stringid(87571563,1)) then  --"是否以墓地龙族怪兽为对象发动？"
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION+CATEGORY_GRAVE_SPSUMMON)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e:SetOperation(c87571563.activate)
		-- 提示玩家选择效果的对象
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
		-- 让玩家选择自己墓地1只满足条件的龙族怪兽作为对象
		local g=Duel.SelectTarget(tp,c87571563.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	else
		e:SetCategory(0)
		e:SetProperty(0)
		e:SetOperation(nil)
	end
end
-- 魔法卡发动时的效果处理（加入手卡或特殊召唤）
function c87571563.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 检查并处理“王家长眠之谷”对墓地卡片操作的无效化效果
		if aux.NecroValleyNegateCheck(tc) then return end
		-- 过滤受“王家长眠之谷”影响无法操作的卡片
		if not aux.NecroValleyFilter()(tc) then return end
		-- 检查自己场上是否有空余的主要怪兽区域，且对象怪兽是否可以特殊召唤
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
			-- 如果不能加入手卡，或者玩家在“加入手卡”和“特殊召唤”中选择了“特殊召唤”
			and (not tc:IsAbleToHand() or Duel.SelectOption(tp,1190,1152)==1) then
			-- 将对象怪兽以表侧表示特殊召唤到自己场上
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		else
			-- 将对象怪兽加入手卡
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 让对方玩家确认加入手卡的卡片
			Duel.ConfirmCards(1-tp,tc)
		end
	end
end
-- 定义用于过滤自己场上表侧表示龙族怪兽的过滤函数
function c87571563.seqfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON)
end
-- 移动怪兽位置效果的启动与对象选择处理函数
function c87571563.seqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c87571563.seqfilter(chkc) end
	-- 检查自己场上是否存在可以作为对象的表侧表示龙族怪兽
	if chk==0 then return Duel.IsExistingTarget(c87571563.seqfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查自己场上是否有可用的主要怪兽区域空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0)>0 end
	-- 提示玩家选择要移动位置的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(87571563,2))  --"请选择要移动位置的卡"
	-- 让玩家选择自己场上1只表侧表示的龙族怪兽作为对象
	Duel.SelectTarget(tp,c87571563.seqfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 移动怪兽位置效果的执行处理函数
function c87571563.seqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取要移动位置的对象怪兽
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) or tc:IsImmuneToEffect(e)
		-- 如果自己场上没有可用的主要怪兽区域空位，则结束效果处理
		or Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0)<=0 then return end
	-- 提示玩家选择要移动到的怪兽区域
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)  --"请选择要移动到的位置"
	-- 让玩家选择自己场上1个可用的主要怪兽区域
	local s=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,0)
	local nseq=math.log(s,2)
	-- 将对象怪兽移动到玩家选择的怪兽区域
	Duel.MoveSequence(tc,nseq)
end
