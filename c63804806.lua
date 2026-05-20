--スピード・キング☆スカル・フレイム
-- 效果：
-- 这张卡不能通常召唤。把自己墓地存在的1只「骷髅炎鬼」从游戏中除外的场合可以特殊召唤。1回合1次，可以给与对方基本分自己墓地存在的「燃烧骷髅头」数量×400的数值的伤害。此外，这张卡从场上送去墓地时，可以把自己墓地存在的1只「骷髅炎鬼」特殊召唤。
function c63804806.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。把自己墓地存在的1只「骷髅炎鬼」从游戏中除外的场合可以特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c63804806.spcon)
	e1:SetTarget(c63804806.sptg)
	e1:SetOperation(c63804806.spop)
	c:RegisterEffect(e1)
	-- 1回合1次，可以给与对方基本分自己墓地存在的「燃烧骷髅头」数量×400的数值的伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(63804806,0))  --"伤害"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c63804806.damtg)
	e2:SetOperation(c63804806.damop)
	c:RegisterEffect(e2)
	-- 此外，这张卡从场上送去墓地时，可以把自己墓地存在的1只「骷髅炎鬼」特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(63804806,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(c63804806.spcon2)
	e3:SetTarget(c63804806.sptg2)
	e3:SetOperation(c63804806.spop2)
	c:RegisterEffect(e3)
end
-- 过滤条件：墓地中卡名为「骷髅炎鬼」且可以作为Cost除外的卡片
function c63804806.spfilter(c)
	return c:IsCode(99899504) and c:IsAbleToRemoveAsCost()
end
-- 特殊召唤规则的条件判定函数
function c63804806.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否有可用的怪兽区域空格
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1张满足过滤条件的「骷髅炎鬼」
		and Duel.IsExistingMatchingCard(c63804806.spfilter,tp,LOCATION_GRAVE,0,1,nil)
end
-- 特殊召唤规则的消耗/目标选择函数
function c63804806.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己墓地中所有满足过滤条件的「骷髅炎鬼」卡片组
	local g=Duel.GetMatchingGroup(c63804806.spfilter,tp,LOCATION_GRAVE,0,nil)
	-- 给玩家发送“选择要除外的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤规则的执行操作函数
function c63804806.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的卡片以特殊召唤的消耗为由表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
end
-- 伤害效果的发动准备与目标确认函数
function c63804806.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在至少1张「燃烧骷髅头」
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,26293219) end
	-- 计算自己墓地中「燃烧骷髅头」的数量乘以400的伤害数值
	local dam=Duel.GetMatchingGroupCount(Card.IsCode,tp,LOCATION_GRAVE,0,nil,26293219)*400
	-- 设置效果处理的对象玩家为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置效果处理的对象参数为计算出的伤害数值
	Duel.SetTargetParam(dam)
	-- 设置当前连锁的操作信息为给与对方玩家指定数值的伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 伤害效果的执行函数
function c63804806.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 重新计算并获取当前自己墓地中「燃烧骷髅头」数量乘以400的伤害数值
	local d=Duel.GetMatchingGroupCount(Card.IsCode,tp,LOCATION_GRAVE,0,nil,26293219)*400
	-- 以效果伤害的形式给与目标玩家计算出的伤害数值
	Duel.Damage(p,d,REASON_EFFECT)
end
-- 判定此卡是否从场上送去墓地，作为特殊召唤效果的发动条件
function c63804806.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤条件：墓地中卡名为「骷髅炎鬼」且可以被特殊召唤的怪兽
function c63804806.spfilter2(c,e,tp)
	return c:IsCode(99899504) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的发动准备与目标选择函数
function c63804806.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c63804806.spfilter2(chkc,e,tp) end
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在可以作为效果对象的「骷髅炎鬼」
		and Duel.IsExistingTarget(c63804806.spfilter2,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 给玩家发送“选择要特殊召唤的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地中1只满足条件的「骷髅炎鬼」作为效果对象
	local g=Duel.SelectTarget(tp,c63804806.spfilter2,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置当前连锁的操作信息为特殊召唤选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 特殊召唤效果的执行函数
function c63804806.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的第一个效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
