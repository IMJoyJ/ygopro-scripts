--リブロマンサー・リアライズ
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：把手卡1只「书灵师」仪式怪兽给对方观看才能发动。把持有和给人观看的怪兽的等级相同等级的1只「炽火衍生物」（电子界族·炎·攻/守0）在自己场上特殊召唤。只要这个效果特殊召唤的衍生物在自己场上存在，自己不是「书灵师」怪兽不能特殊召唤。
local s,id,o=GetID()
-- 注册场地魔法卡的发动效果，使卡能被正常发动
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- ①：把手卡1只「书灵师」仪式怪兽给对方观看才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,id)
	e1:SetLabel(0)
	e1:SetCost(s.cost)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end
-- 过滤手牌中满足条件的「书灵师」仪式怪兽，用于cost判定
function s.cfilter(c,tp)
	return c:IsSetCard(0x17c) and c:IsType(TYPE_MONSTER) and c:IsType(TYPE_RITUAL) and not c:IsPublic()
		-- 检查玩家是否可以特殊召唤指定等级的衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,0,0,c:GetLevel(),RACE_CYBERSE,ATTRIBUTE_FIRE)
end
-- 处理效果的cost阶段，选择并确认手牌中的仪式怪兽
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	-- 检查手牌中是否存在满足条件的「书灵师」仪式怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil,tp) end
	-- 提示玩家选择要给对方确认的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 从手牌中选择一张满足条件的「书灵师」仪式怪兽
	local tc=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,nil,tp):GetFirst()
	-- 向对方确认所选的仪式怪兽
	Duel.ConfirmCards(1-tp,tc)
	e:SetLabel(tc:GetLevel())
	-- 将手牌洗切
	Duel.ShuffleHand(tp)
end
-- 处理效果的发动判定，检查是否满足发动条件
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local res=e:GetLabel()==100
		e:SetLabel(0)
		-- 检查是否满足特殊召唤衍生物的条件
		return res and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	end
	-- 设置效果发动信息，表示将特殊召唤衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置效果发动信息，表示将特殊召唤衍生物
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 处理效果的发动，创建并特殊召唤衍生物
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local lv=e:GetLabel()
	-- 检查场上是否有空位可特殊召唤衍生物
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否可以特殊召唤指定等级的衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,0,0,lv,RACE_CYBERSE,ATTRIBUTE_FIRE) then
		-- 创建一张指定编号的衍生物
		local tk=Duel.CreateToken(tp,id+o)
		-- 设置衍生物的等级为所选仪式怪兽的等级
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
		e1:SetValue(lv)
		tk:RegisterEffect(e1,true)
		-- 将衍生物特殊召唤到场上
		Duel.SpecialSummonStep(tk,0,tp,tp,false,false,POS_FACEUP)
		-- 设置永续效果，限制玩家不能特殊召唤非「书灵师」怪兽
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetRange(LOCATION_MZONE)
		e2:SetAbsoluteRange(tp,1,0)
		e2:SetCondition(s.splimitcon)
		e2:SetTarget(s.splimit)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tk:RegisterEffect(e2,true)
		-- 完成特殊召唤流程
		Duel.SpecialSummonComplete()
	end
end
-- 限制效果的触发条件，确保只对自身玩家生效
function s.splimitcon(e)
	return e:GetHandlerPlayer()==e:GetOwnerPlayer()
end
-- 限制效果的目标，禁止特殊召唤非「书灵师」怪兽
function s.splimit(e,c)
	return not c:IsSetCard(0x17c)
end
