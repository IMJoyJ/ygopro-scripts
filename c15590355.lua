--リブロマンサー・リアライズ
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：把手卡1只「书灵师」仪式怪兽给对方观看才能发动。把持有和给人观看的怪兽的等级相同等级的1只「炽火衍生物」（电子界族·炎·攻/守0）在自己场上特殊召唤。只要这个效果特殊召唤的衍生物在自己场上存在，自己不是「书灵师」怪兽不能特殊召唤。
local s,id,o=GetID()
-- 注册魔法卡发动所需的‘允许发动’空效果，并注册①效果为起动效果，设置其类别、发动位置、1回合1次限制、代价、目标与处理函数。
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- 这个卡名的①的效果1回合只能使用1次。①：把手卡1只「书灵师」仪式怪兽给对方观看才能发动。把持有和给人观看的怪兽的等级相同等级的1只「炽火衍生物」（电子界族·炎·攻/守0）在自己场上特殊召唤。只要这个效果特殊召唤的衍生物在自己场上存在，自己不是「书灵师」怪兽不能特殊召唤。
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
-- 过滤函数：筛选手卡中满足「书灵师」字段、怪兽类型、仪式类型、未公开且玩家能够特殊召唤对应等级衍生物的怪兽，作为展示代价的候选。
function s.cfilter(c,tp)
	return c:IsSetCard(0x17c) and c:IsType(TYPE_MONSTER) and c:IsType(TYPE_RITUAL) and not c:IsPublic()
		-- 确认玩家tp能够以表侧表示特殊召唤1只电子界族·炎属性·攻/守0、等级等于候选怪兽等级的「炽火衍生物」到自身场上。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,0,0,c:GetLevel(),RACE_CYBERSE,ATTRIBUTE_FIRE)
end
-- 支付代价：先标记代价已执行（Label=100）；若有可展示的「书灵师」仪式怪兽，则选择1只给对方确认，记录其等级，并洗切手卡。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	-- 检查手卡中是否存在至少1只满足条件的「书灵师」仪式怪兽（且可特招对应衍生物），作为代价是否可支付的判断。
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil,tp) end
	-- 弹出选择提示，要求玩家选择1张手卡用于给对方确认（HINTMSG_CONFIRM）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 玩家从手卡选择1只符合条件的「书灵师」仪式怪兽，用于执行展示代价。
	local tc=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,nil,tp):GetFirst()
	-- 将选择的怪兽卡给对方玩家确认，完成‘给对方观看’的条件。
	Duel.ConfirmCards(1-tp,tc)
	e:SetLabel(tc:GetLevel())
	-- 展示后洗切手卡，避免手牌顺序信息被对方获知。
	Duel.ShuffleHand(tp)
end
-- 目标判定：确认代价已执行（Label=100）且己方主要怪兽区有空位；若满足则设置效果处理将生成衍生物并进行特殊召唤的操作信息。
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local res=e:GetLabel()==100
		e:SetLabel(0)
		-- 效果可发动的条件：已经支付过展示代价，并且己方主要怪兽区仍有空位。
		return res and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	end
	-- 设置操作信息：本次效果处理将生成1只衍生物（用于连锁/效果检测）。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息：本次效果处理将进行1只怪兽的特殊召唤（用于连锁/效果检测）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 效果处理：按记录的等级生成「炽火衍生物」并特殊召唤到己方场上；随后给该衍生物附加等级变更效果和自肃效果（只要此衍生物在己方场上存在，自己不能特殊召唤「书灵师」以外的怪兽）。
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local lv=e:GetLabel()
	-- 处理时再次确认己方主要怪兽区仍有空位。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 处理时再次确认玩家仍能特殊召唤对应等级/种族/属性的衍生物。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,0,0,lv,RACE_CYBERSE,ATTRIBUTE_FIRE) then
		-- 创建1只「炽火衍生物」（卡号id+o）作为待特殊召唤的token。
		local tk=Duel.CreateToken(tp,id+o)
		-- 把持有和给人观看的怪兽的等级相同等级的1只「炽火衍生物」（电子界族·炎·攻/守0）在自己场上特殊召唤。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
		e1:SetValue(lv)
		tk:RegisterEffect(e1,true)
		-- 将token以表侧表示特殊召唤到己方场上（作为连续特殊召唤过程的一步）。
		Duel.SpecialSummonStep(tk,0,tp,tp,false,false,POS_FACEUP)
		-- 只要这个效果特殊召唤的衍生物在自己场上存在，自己不是「书灵师」怪兽不能特殊召唤。
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
		-- 结束连续特殊召唤处理，正式完成特殊召唤。
		Duel.SpecialSummonComplete()
	end
end
-- 自肃效果的适用条件：该衍生物的控制者与持有者相同（即衍生物仍在召唤者自己场上）。
function s.splimitcon(e)
	return e:GetHandlerPlayer()==e:GetOwnerPlayer()
end
-- 自肃效果的对象限制：不能特殊召唤非「书灵师」字段的怪兽。
function s.splimit(e,c)
	return not c:IsSetCard(0x17c)
end
