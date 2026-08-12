--呪符竜
-- 效果：
-- 「黑魔术师」＋龙族怪兽
-- 这张卡用以上记的卡为融合素材的融合召唤以及用「蒂迈欧之眼」的效果才能特殊召唤。
-- ①：这张卡特殊召唤的场合，以自己·对方的墓地的魔法卡任意数量为对象发动。那些卡除外，这张卡的攻击力上升除外的卡数量×100。
-- ②：这张卡被破坏的场合，以自己墓地1只魔法师族怪兽为对象才能发动。那只魔法师族怪兽特殊召唤。
function c75380687.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合素材为「黑魔术师」和1只龙族怪兽
	aux.AddFusionProcCodeFun(c,46986414,aux.FilterBoolFunction(Card.IsRace,RACE_DRAGON),1,false,false)
	-- 这张卡用以上记的卡为融合素材的融合召唤以及用「蒂迈欧之眼」的效果才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c75380687.splimit)
	c:RegisterEffect(e1)
	-- ①：这张卡特殊召唤的场合，以自己·对方的墓地的魔法卡任意数量为对象发动。那些卡除外，这张卡的攻击力上升除外的卡数量×100。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(75380687,0))  --"除外"
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetTarget(c75380687.target)
	e2:SetOperation(c75380687.operation)
	c:RegisterEffect(e2)
	-- ②：这张卡被破坏的场合，以自己墓地1只魔法师族怪兽为对象才能发动。那只魔法师族怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(75380687,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetTarget(c75380687.sptg)
	e3:SetOperation(c75380687.spop)
	c:RegisterEffect(e3)
end
-- 限制特殊召唤条件为融合召唤，或者通过「蒂迈欧之眼」的效果特殊召唤
function c75380687.splimit(e,se,sp,st)
	return bit.band(st,SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION or se:GetHandler():IsCode(1784686)
end
-- 过滤墓地中可以除外的魔法卡
function c75380687.filter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToRemove()
end
-- 效果①的靶向处理，选择双方墓地任意数量的魔法卡作为对象
function c75380687.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and c75380687.filter(chkc) end
	if chk==0 then return true end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择双方墓地中任意数量（1到120张）的魔法卡作为对象
	local g=Duel.SelectTarget(tp,c75380687.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,120,nil)
	-- 设置除外操作的连锁信息
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),PLAYER_ALL,LOCATION_GRAVE)
end
-- 效果①的执行处理，除外对象卡片并根据除外数量提升自身攻击力
function c75380687.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍与效果相关的对象卡片
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 将对象卡片表侧表示除外，并获取实际除外的卡片数量
	local ct=Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	local c=e:GetHandler()
	if ct>0 and c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的攻击力上升除外的卡数量×100。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		e1:SetValue(ct*100)
		c:RegisterEffect(e1)
	end
end
-- 过滤自己墓地中可以特殊召唤的魔法师族怪兽
function c75380687.spfilter(c,e,tp)
	return c:IsRace(RACE_SPELLCASTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的靶向处理，检查怪兽区域空位并选择自己墓地1只魔法师族怪兽作为对象
function c75380687.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c75380687.spfilter(chkc,e,tp) end
	-- 检查当前玩家的怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在可以特殊召唤的魔法师族怪兽
		and Duel.IsExistingTarget(c75380687.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只魔法师族怪兽作为对象
	local g=Duel.SelectTarget(tp,c75380687.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置特殊召唤操作的连锁信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果②的执行处理，将作为对象的魔法师族怪兽特殊召唤
function c75380687.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsRace(RACE_SPELLCASTER) then
		-- 将目标怪兽表侧表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
