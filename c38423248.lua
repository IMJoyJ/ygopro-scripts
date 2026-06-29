--召喚獣マギストス・セリオン
-- 效果：
-- 「召唤师 阿莱斯特」＋融合·同调·超量·连接怪兽
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤的场合，以自己墓地1只融合·同调·超量·连接怪兽和场上1只怪兽为对象才能发动。那些怪兽除外。
-- ②：融合召唤的这张卡被战斗·效果破坏的场合才能发动。从卡组把1只魔法师族·4星怪兽特殊召唤。那之后，可以把这张卡当作攻击力上升1000的装备魔法卡使用给那只怪兽装备。
local s,id,o=GetID()
-- 注册特殊召唤成功时除外墓地额外怪兽与场上怪兽、以及融合召唤的此卡被破坏时特召魔法师族怪兽并装备自身的效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 注册融合召唤的素材要求：以「召唤师 阿莱斯特」与融合/同调/超量/连接怪兽为素材
	aux.AddFusionProcCodeFun(c,86120751,aux.FilterBoolFunction(Card.IsFusionType,TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK),1,true,true)
	-- ①：这张卡特殊召唤的场合，以自己墓地1只融合·同调·超量·连接怪兽和场上1只怪兽为对象才能发动。那些怪兽除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"除外"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
	-- ②：融合召唤的这张卡被战斗·效果破坏的场合才能发动。从卡组把1只魔法师族·4星怪兽特殊召唤。那之后，可以把这张卡当作攻击力上升1000的装备魔法卡使用给那只怪兽装备。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.material_type=TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK
-- 自己墓地中的融合、同调、超量或连接怪兽的过滤条件
function s.rmfilter(c,tp)
	return c:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK)
		and c:IsAbleToRemove()
end
-- 墓地与场上怪兽除外效果的发动准备与对象选择
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己墓地是否存在符合条件的融合、同调、超量或连接怪兽
	if chk==0 then return Duel.IsExistingTarget(s.rmfilter,tp,LOCATION_GRAVE,0,1,nil,tp)
		-- 检查双方场上是否存在可以除外的怪兽
		and Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家发送提示，请选择要从墓地除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从墓地中选择1只融合/同调/超量/连接怪兽作为除外对象
	local g1=Duel.SelectTarget(tp,s.rmfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp)
	-- 向玩家发送提示，请选择要从场上除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从场上选择1只怪兽作为除外对象
	local g2=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	g1:Merge(g2)
	-- 设置操作信息为将选中的墓地与场上怪兽除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g1,g1:GetCount(),0,0)
end
-- 除外效果的执行
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中关联的全部作为对象的卡片
	local g=Duel.GetTargetsRelateToChain()
	-- 从对象中筛选出仍然存在的怪兽卡片
	local tg=g:Filter(aux.NecroValleyFilter(Card.IsType),nil,TYPE_MONSTER)
	if tg:GetCount()>0 then
		-- 将筛选出的怪兽卡片以表侧表示除外
		Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)
	end
end
-- 确认作为融合召唤的此卡在怪兽区域被战斗或效果破坏
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0 and c:IsSummonType(SUMMON_TYPE_FUSION)
		and c:IsPreviousLocation(LOCATION_MZONE)
end
-- 卡组中可特殊召唤的4星·魔法师族怪兽的过滤条件
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_SPELLCASTER) and c:IsLevel(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特召效果的发动准备与合法性检查
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空闲的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在符合特殊召唤条件的4星魔法师族怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息为从卡组特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 特召魔法师族怪兽以及当作装备卡使用给该怪兽装备效果的执行
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认场上是否有可用于特召的怪兽格，若无则停止处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家提示选择需要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1只4星魔法师族怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 若该怪兽特殊召唤成功，则继续处理后续的装备卡判定
	if tc and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0
		-- 检查自己魔陷区域是否有空余的装备卡区域
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 询问玩家是否选择将此卡当作装备卡给该特召的怪兽装备
		and c:IsRelateToChain() and aux.NecroValleyFilter()(c) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否装备？"
		-- 决定进行装备时，切断连锁以执行后续动作
		Duel.BreakEffect()
		-- 将作为破坏状态的此卡作为装备卡给特召的怪兽装备
		if not Duel.Equip(tp,c,tc) then return end
		-- 注册装备在此卡上的怪兽格限定的单体装备限制效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetLabelObject(tc)
		e1:SetValue(s.eqlimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		-- 注册给装备怪兽攻击力上升1000的单体装备加值持续效果
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(1000)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
	end
end
-- 限制此装备卡只能装备给上述特殊召唤的怪兽
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end
