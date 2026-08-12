--モノケロース
-- 效果：
-- 这张卡不能通常召唤。把手卡1张魔法卡从游戏中除外的场合可以特殊召唤。这张卡和兽族调整为素材的同调召唤成功时，可以把1只作为那次同调召唤的素材的兽族调整从墓地特殊召唤。
function c58807980.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。把手卡1张魔法卡从游戏中除外的场合可以特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c58807980.hspcon)
	e1:SetTarget(c58807980.hsptg)
	e1:SetOperation(c58807980.hspop)
	c:RegisterEffect(e1)
	-- 这张卡和兽族调整为素材的同调召唤成功时，可以把1只作为那次同调召唤的素材的兽族调整从墓地特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(58807980,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCondition(c58807980.spcon)
	e2:SetTarget(c58807980.sptg)
	e2:SetOperation(c58807980.spop)
	c:RegisterEffect(e2)
end
-- 过滤手牌中可作为特殊召唤Cost除外的魔法卡
function c58807980.cfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToRemoveAsCost()
end
-- 特殊召唤规则的发动条件：自身怪兽区域有空位，且手牌有可除外的魔法卡
function c58807980.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否有可用的怪兽区域空格
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在至少1张满足过滤条件的魔法卡
		and Duel.IsExistingMatchingCard(c58807980.cfilter,tp,LOCATION_HAND,0,1,nil)
end
-- 特殊召唤规则的目标：选择手牌中1张要除外的魔法卡并记录
function c58807980.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取手牌中所有满足过滤条件的魔法卡组
	local g=Duel.GetMatchingGroup(c58807980.cfilter,tp,LOCATION_HAND,0,nil)
	-- 给玩家发送“请选择要除外的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤规则的操作：将选中的魔法卡除外
function c58807980.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的卡以特殊召唤为原因表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
end
-- 诱发效果的发动条件：自身在墓地且作为同调召唤的素材
function c58807980.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end
-- 过滤墓地中可作为效果对象且可特殊召唤的兽族调整怪兽
function c58807980.filter(c,e,tp)
	return c:IsLocation(LOCATION_GRAVE) and c:IsType(TYPE_TUNER) and c:IsRace(RACE_BEAST)
		and c:IsCanBeEffectTarget(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 诱发效果的目标：获取同调召唤的素材，并从中选择1只符合条件的兽族调整作为效果对象
function c58807980.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local mg=e:GetHandler():GetReasonCard():GetMaterial()
	if chkc then return mg:IsContains(chkc) and c58807980.filter(chkc,e,tp) end
	-- 在发动效果的初步检查中，确认自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and mg:IsExists(c58807980.filter,1,nil,e,tp) end
	-- 给玩家发送“请选择要特殊召唤的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local g=mg:FilterSelect(tp,c58807980.filter,1,1,nil,e,tp)
	-- 将选中的兽族调整怪兽设置为当前连锁的效果对象
	Duel.SetTargetCard(g)
	-- 设置当前连锁的操作信息为“特殊召唤1只选中的怪兽”
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 诱发效果的操作：将作为效果对象的兽族调整从墓地特殊召唤
function c58807980.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为效果对象的卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到自己的场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
