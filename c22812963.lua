--創世の神 デウテロノミオン
-- 效果：
-- 这张卡不能通常召唤。「创世之神 狄特罗诺米安」1回合1次在把原本攻击力和原本守备力是2500的自己场上1只表侧表示怪兽除外的场合才能特殊召唤。
-- ①：这张卡特殊召唤的场合才能发动。从卡组把1张「再世」魔法·陷阱卡在自己场上盖放。
-- ②：这张卡的攻击力在战斗阶段内上升2500。
-- ③：这张卡向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
local s,id,o=GetID()
-- 初始化怪兽的全部效果：给这张卡附加苏生限制；设置“不能通常召唤”的特殊召唤条件；注册手牌中的规则特殊召唤效果；注册特殊召唤成功时从卡组盖放「再世」魔法·陷阱卡的诱发效果；注册战斗阶段攻击力上升效果；注册贯穿伤害效果。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 「创世之神 狄特罗诺米安」1回合1次在把原本攻击力和原本守备力是2500的自己场上1只表侧表示怪兽除外的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- ①：这张卡特殊召唤的场合才能发动。从卡组把1张「再世」魔法·陷阱卡在自己场上盖放。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"盖放"
	e3:SetCategory(CATEGORY_SSET)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetTarget(s.settg)
	e3:SetOperation(s.setop)
	c:RegisterEffect(e3)
	-- ②：这张卡的攻击力在战斗阶段内上升2500。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(s.atkcon)
	e4:SetValue(2500)
	c:RegisterEffect(e4)
	-- ③：这张卡向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e5)
end
-- 筛选可作为特殊召唤代价的怪兽：必须是表侧表示，原本攻击力和原本守备力都为2500，且能够作为代价除外，除外后自己场上仍有怪兽区空格可特殊召唤此卡。
function s.spfilter(c,tp)
	return c:IsFaceup() and c:GetBaseAttack()==2500 and c:GetBaseDefense()==2500 and c:IsAbleToRemoveAsCost()
		-- 确认该怪兽能被表侧表示除外作为特殊召唤代价，且除外它后自己场上仍有怪兽区空位。
		and c:IsAbleToRemove(tp,POS_FACEUP,REASON_SPSUMMON) and Duel.GetMZoneCount(tp,c)>0
end
-- 判定手牌中的这张卡能否通过自身的规则效果特殊召唤：若自己场上存在至少1只满足代价条件的怪兽（表侧·原本攻守2500·可除外·除外后有空位），则满足特殊召唤条件。
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否存在至少1只满足特殊召唤代价条件的表侧表示怪兽（原本攻守2500且可除外并腾出空格）。
	return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_MZONE,0,1,nil,tp)
end
-- 特殊召唤手续中的选择处理：从自己场上满足条件的怪兽中选择1只作为除外代价；选中后将卡记录在效果对象中，供后续除外操作使用。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己场上所有满足特殊召唤代价过滤条件的怪兽，作为可选择的候选集合。
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_MZONE,0,nil,tp)
	-- 向当前玩家显示‘请选择要除外的卡’的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤手续的处理：将记录好的那只怪兽除外，支付特殊召唤的代价。
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 以表侧表示除外选中的怪兽，除外原因为特殊召唤（REASON_SPSUMMON）。
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
end
-- 过滤可盖放的卡：卡名含有「再世」字段（0x1c5）的魔法·陷阱卡，并且当前可以盖放（不受‘不能盖放’限制）。
function s.setfilter(c)
	return c:IsSetCard(0x1c5) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- ①效果的发动条件：自己魔陷区有空位，且卡组中存在符合条件的「再世」魔法·陷阱卡。
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动时检查自己魔陷区是否有空余区域用于盖放。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 同时检查卡组中是否存在至少1张符合条件的「再世」魔法·陷阱卡。
		and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- ①效果的处理：在魔陷区有空位的前提下，从卡组选择1张符合条件的「再世」魔法·陷阱卡盖放到自己场上。
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理前再次确认魔陷区有空位，若已没有空位则直接结束处理。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 向当前玩家显示‘请选择要盖放的卡’的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从卡组中选出1张符合条件的「再世」魔法·陷阱卡。
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的那张「再世」魔法·陷阱卡盖放到自己场上。
		Duel.SSet(tp,tc)
	end
end
-- ②攻击力上升效果的发动条件：当前处于战斗阶段。
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否为战斗阶段，是则返回true，此时攻击力上升效果适用。
	return Duel.IsBattlePhase()
end
