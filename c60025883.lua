--決闘竜 デュエル・リンク・ドラゴン
-- 效果：
-- 包含同调怪兽的怪兽2只以上
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己·对方的主要阶段，从额外卡组把1只「动力工具」同调怪兽或者7·8星的龙族同调怪兽除外才能发动。把持有和那只怪兽相同种族·属性·等级·攻击力·守备力的1只「决斗龙衍生物」在作为这张卡所连接区的自己场上特殊召唤。
-- ②：自己场上有「决斗龙衍生物」存在的场合，对方不能选择这张卡作为攻击对象，也不能作为效果的对象。
function c60025883.initial_effect(c)
	-- 为这张卡添加连接召唤手续：需要2只以上的怪兽作为素材，且必须满足lcheck过滤条件。
	aux.AddLinkProcedure(c,nil,2,nil,c60025883.lcheck)
	c:EnableReviveLimit()
	-- ①：自己·对方的主要阶段，从额外卡组把1只「动力工具」同调怪兽或者7·8星的龙族同调怪兽除外才能发动。把持有和那只怪兽相同种族·属性·等级·攻击力·守备力的1只「决斗龙衍生物」在作为这张卡所连接区的自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(60025883,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,60025883)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	e1:SetCondition(c60025883.spcon)
	e1:SetCost(c60025883.spcost)
	e1:SetTarget(c60025883.sptg)
	e1:SetOperation(c60025883.spop)
	c:RegisterEffect(e1)
	-- ②：自己场上有「决斗龙衍生物」存在的场合，对方不能选择这张卡作为攻击对象
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c60025883.tgcon)
	-- 设置不能成为攻击对象效果的过滤函数（自身不会被选为攻击对象）。
	e2:SetValue(aux.imval1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	-- 设置不能成为对方效果对象效果的过滤函数（自身不会被对方选为效果对象）。
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
end
-- 连接素材的过滤条件：素材组中必须存在至少1只同调怪兽。
function c60025883.lcheck(g,lc)
	return g:IsExists(Card.IsLinkType,1,nil,TYPE_SYNCHRO)
end
-- 效果①的发动条件：自己或对方的主要阶段。
function c60025883.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的阶段。
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or ph==PHASE_MAIN2
end
-- 过滤额外卡组中可以作为Cost除外的「动力工具」同调怪兽或7·8星龙族同调怪兽，且该怪兽的数据能用于特殊召唤衍生物。
function c60025883.costfilter(c,e,tp)
	return c:IsType(TYPE_SYNCHRO) and c:IsAbleToRemoveAsCost()
		and (c:IsSetCard(0xc2) or c:IsRace(RACE_DRAGON) and (c:IsLevel(7) or c:IsLevel(8)))
		-- 检查玩家是否能以该怪兽的攻击力、守备力、等级、种族、属性特殊召唤衍生物。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,60025884,0,TYPES_TOKEN_MONSTER,c:GetAttack(),c:GetDefense(),c:GetLevel(),c:GetRace(),c:GetAttribute())
end
-- 效果①的Cost：从额外卡组将1只满足条件的同调怪兽除外，并记录该怪兽。
function c60025883.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查额外卡组是否存在可作为Cost除外且能成功特招衍生物的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c60025883.costfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 提示玩家选择要除外的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择1只满足条件的额外卡组怪兽。
	local g=Duel.SelectMatchingCard(tp,c60025883.costfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	-- 将选中的怪兽表侧表示除外作为发动Cost。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	e:SetLabelObject(g:GetFirst())
end
-- 效果①的Target：检查自身连接端是否有空位，并设置特殊召唤和衍生物生成的操作信息。
function c60025883.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local zone=bit.band(e:GetHandler():GetLinkedZone(tp),0x1f)
	-- 检查自身所连接的区域是否有可用的怪兽区域空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)>0 and zone~=0 end
	-- 设置特殊召唤的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
	-- 设置生成衍生物的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
end
-- 效果①的效果处理：在自身的连接端特殊召唤一只「决斗龙衍生物」，并将其数值设定为与除外怪兽相同。
function c60025883.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local zone=bit.band(c:GetLinkedZone(tp),0x1f)
	local tc=e:GetLabelObject()
	local atk=tc:GetTextAttack()
	local def=tc:GetTextDefense()
	local lv=tc:GetOriginalLevel()
	local race=tc:GetOriginalRace()
	local att=tc:GetOriginalAttribute()
	-- 检查连接端是否仍有可用的怪兽区域空位，若无则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)<=0
		-- 检查是否仍能特殊召唤该属性、种族等数值的衍生物，若不能则不处理。
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,60025884,0,TYPES_TOKEN_MONSTER,atk,def,lv,race,att) then return end
	-- 创建「决斗龙衍生物」的卡片数据。
	local token=Duel.CreateToken(tp,60025884)
	-- 将衍生物以表侧表示特殊召唤到自身的连接端区域（分步处理）。
	Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP,zone)
	-- 把持有和那只怪兽相同...攻击力...的1只「决斗龙衍生物」在作为这张卡所连接区的自己场上特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK)
	e1:SetValue(atk)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
	token:RegisterEffect(e1)
	-- 把持有和那只怪兽相同...守备力...的1只「决斗龙衍生物」在作为这张卡所连接区的自己场上特殊召唤
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SET_DEFENSE)
	e2:SetValue(def)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
	token:RegisterEffect(e2)
	-- 把持有和那只怪兽相同...属性...的1只「决斗龙衍生物」在作为这张卡所连接区的自己场上特殊召唤
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CHANGE_ATTRIBUTE)
	e3:SetValue(att)
	token:RegisterEffect(e3)
	-- 把持有和那只怪兽相同...等级...的1只「决斗龙衍生物」在作为这张卡所连接区的自己场上特殊召唤
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_CHANGE_LEVEL)
	e4:SetValue(lv)
	token:RegisterEffect(e4)
	-- 把持有和那只怪兽相同种族...的1只「决斗龙衍生物」在作为这张卡所连接区的自己场上特殊召唤
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_CHANGE_RACE)
	e5:SetValue(race)
	token:RegisterEffect(e5)
	-- 完成特殊召唤的流程。
	Duel.SpecialSummonComplete()
end
-- 过滤场上的「决斗龙衍生物」。
function c60025883.tgfilter(c)
	return c:GetOriginalCode()==60025884
end
-- 效果②的适用条件：自己场上有「决斗龙衍生物」存在。
function c60025883.tgcon(e)
	-- 检查自己场上是否存在「决斗龙衍生物」。
	return Duel.IsExistingMatchingCard(c60025883.tgfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
end
