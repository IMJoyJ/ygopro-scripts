--召喚獣マギストス・セリオン
-- 效果：
-- 「召唤师 阿莱斯特」＋融合·同调·超量·连接怪兽
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤的场合，以自己墓地1只融合·同调·超量·连接怪兽和场上1只怪兽为对象才能发动。那些怪兽除外。
-- ②：融合召唤的这张卡被战斗·效果破坏的场合才能发动。从卡组把1只魔法师族·4星怪兽特殊召唤。那之后，可以把这张卡当作攻击力上升1000的装备魔法卡使用给那只怪兽装备。
local s,id,o=GetID()
-- 初始化卡片：设置苏生限制与融合素材条件，并注册①效果（特殊召唤成功的场合除外怪兽，1回合1次）和②效果（被破坏时从卡组特殊召唤并可装备，1回合1次）
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 设定融合召唤手续：以「召唤师 阿莱斯特」和1只融合·同调·超量·连接怪兽为融合素材
	aux.AddFusionProcCodeFun(c,86120751,aux.FilterBoolFunction(Card.IsFusionType,TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK),1,true,true)
	-- ①：这张卡特殊召唤的场合，以自己墓地1只融合·同调·超量·连接怪兽和场上1只怪兽为对象才能发动。那些怪兽除外。这个卡名的①的效果1回合只能使用1次。
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
	-- ②：融合召唤的这张卡被战斗·效果破坏的场合才能发动。从卡组把1只魔法师族·4星怪兽特殊召唤。那之后，可以把这张卡当作攻击力上升1000的装备魔法卡使用给那只怪兽装备。这个卡名的②的效果1回合只能使用1次。
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
-- 除外对象过滤函数：筛选自己墓地中可以被除外的融合·同调·超量·连接怪兽
function s.rmfilter(c,tp)
	return c:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK)
		and c:IsAbleToRemove()
end
-- ①效果的对象选择函数：发动条件检测时确认墓地有可作对象的融合·同调·超量·连接怪兽且场上有可以除外的怪兽
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 发动条件检测：自己墓地存在1只可以成为对象的、可以除外的融合·同调·超量·连接怪兽
	if chk==0 then return Duel.IsExistingTarget(s.rmfilter,tp,LOCATION_GRAVE,0,1,nil,tp)
		-- 发动条件检测：双方怪兽区域存在1只可以成为对象的、可以除外的怪兽
		and Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让自己玩家选择自己墓地1只可以除外的融合·同调·超量·连接怪兽作为对象
	local g1=Duel.SelectTarget(tp,s.rmfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp)
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让双方怪兽区域中选择1只可以除外的怪兽作为对象
	local g2=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	g1:Merge(g2)
	-- 设置连锁操作信息：本次连锁将以效果除外2张作为对象的卡，供星尘龙等效果的发动检测使用
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g1,g1:GetCount(),0,0)
end
-- ①效果的处理函数：取得与连锁关联的对象卡，过滤出其中不受王家长眠之谷影响的怪兽，将它们以表侧表示除外
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁处理时仍然与连锁关联的对象卡组
	local g=Duel.GetTargetsRelateToChain()
	-- 从对象中过滤出不受王家长眠之谷影响的怪兽（墓地对象受长眠之谷影响时除外处理不适用）
	local tg=g:Filter(aux.NecroValleyFilter(Card.IsType),nil,TYPE_MONSTER)
	if tg:GetCount()>0 then
		-- 将这些怪兽以表侧表示从游戏中除外
		Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)
	end
end
-- ②效果的发动条件：融合召唤的这张卡在怪兽区域被战斗或效果破坏
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0 and c:IsSummonType(SUMMON_TYPE_FUSION)
		and c:IsPreviousLocation(LOCATION_MZONE)
end
-- 特殊召唤过滤函数：筛选卡组中可以被特殊召唤的魔法师族·4星怪兽
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_SPELLCASTER) and c:IsLevel(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的对象·目标函数：发动条件检测时确认自己主要怪兽区域有空位且卡组有可特殊召唤的魔法师族·4星怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检测：自己的主要怪兽区域有可以使用的空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件检测：卡组存在至少1只满足条件的魔法师族·4星怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁操作信息：本次连锁将从卡组特殊召唤1只怪兽，供其他效果的发动检测使用
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ②效果的处理函数：确认怪兽区域有空位后，从卡组选1只魔法师族·4星怪兽特殊召唤，成功且魔法与陷阱区域有空位、这张卡仍与连锁关联且不受长眠之谷影响时询问玩家是否装备，是则把这张卡装备给那只怪兽，并赋予只能装备给该怪兽的限制和攻击力上升1000的效果
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果处理时若自己的主要怪兽区域没有空格则中止处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让自己玩家从卡组选择1只要特殊召唤的魔法师族·4星怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 将选中的怪兽以表侧表示特殊召唤到自己场上，并确认特殊召唤成功
	if tc and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0
		-- 确认自己的魔法与陷阱区域有可以使用的空格（用于装备）
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 确认这张卡仍与连锁关联、不受王家长眠之谷影响，并询问玩家是否把这张卡装备给那只怪兽
		and c:IsRelateToChain() and aux.NecroValleyFilter()(c) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否装备？"
		-- 中断效果处理，使后续的装备处理与特殊召唤视为不同时处理（错开时点）
		Duel.BreakEffect()
		-- 把这张卡当作装备魔法卡装备给那只特殊召唤的怪兽，装备失败则中止处理
		if not Duel.Equip(tp,c,tc) then return end
		-- 可以把这张卡当作装备魔法卡使用给那只怪兽装备（设置只能装备给该怪兽的装备限制）
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetLabelObject(tc)
		e1:SetValue(s.eqlimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		-- 当作攻击力上升1000的装备魔法卡（赋予装备怪兽攻击力上升1000的效果）
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(1000)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
	end
end
-- 装备限制函数：这张卡只能装备给之前特殊召唤的那只怪兽
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end
