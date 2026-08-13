--デス・エンペラー・デーモン
-- 效果：
-- ←0 【灵摆】 0→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：以场上1张其他的表侧表示的魔法·陷阱卡为对象才能发动。那张卡和这张卡破坏。
-- 【怪兽效果】
-- 「恶魔们的玉座」降临
-- 这张卡不用仪式召唤不能特殊召唤。这个卡名的①③的怪兽效果1回合各能使用1次。
-- ①：这张卡从额外卡组仪式召唤的场合才能发动。额外怪兽区域以外的场上的怪兽全部除外。
-- ②：额外怪兽区域的这张卡不受其他怪兽的效果影响。
-- ③：这张卡在额外怪兽区域存在的场合才能发动。自己的手卡·卡组·墓地·除外状态的1只恶魔族怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化效果注册：记录关联卡名“恶魔们的玉座”；允许灵摆召唤；设置只能用仪式召唤的特召限制；注册灵摆区的破坏效果；注册从额外卡组仪式召唤成功时的除外效果；注册额外怪兽区的免疫效果；注册额外怪兽区时的恶魔族特召效果。
function s.initial_effect(c)
	-- 将卡名“恶魔们的玉座”（密码63679166）登记到这张卡的代码列表中，用于关联效果/检索判断。
	aux.AddCodeList(c,63679166)
	c:EnableReviveLimit()
	-- 为这张卡赋予灵摆怪兽属性，使其可以作为灵摆卡发动、放置到灵摆区，并可进行灵摆召唤。
	aux.EnablePendulumAttribute(c)
	-- 「恶魔们的玉座」降临 这张卡不用仪式召唤不能特殊召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤条件的判定函数为aux.ritlimit，即只有仪式召唤才能特殊召唤，实现召唤限制。
	e0:SetValue(aux.ritlimit)
	c:RegisterEffect(e0)
	-- 这个卡名的灵摆效果1回合只能使用1次。①：以场上1张其他的表侧表示的魔法·陷阱卡为对象才能发动。那张卡和这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"破坏效果"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	-- 这个卡名的①③的怪兽效果1回合各能使用1次。①：这张卡从额外卡组仪式召唤的场合才能发动。额外怪兽区域以外的场上的怪兽全部除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"除外效果"
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.rmcon)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
	-- ②：额外怪兽区域的这张卡不受其他怪兽的效果影响。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.econ)
	e3:SetValue(s.efilter)
	c:RegisterEffect(e3)
	-- ③：这张卡在额外怪兽区域存在的场合才能发动。自己的手卡·卡组·墓地·除外状态的1只恶魔族怪兽特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))  --"特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id+o*2)
	e4:SetCondition(s.econ)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end
-- 定义灵摆效果取对象的筛选条件：表侧表示的魔法·陷阱卡（不包括怪兽）。
function s.filter1(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 取对象检查和发动合法性判断：若检查已选对象，则对象必须在场上且是表侧魔陷且不是自身；若检查能否发动，则此卡可被破坏且场上存在其他表侧魔陷可作为对象。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and s.filter1(chkc) and chkc~=e:GetHandler() end
	if chk==0 then return e:GetHandler():IsDestructable()
		-- 检查场上是否存在1张除此卡以外的表侧魔法·陷阱卡，能够成为效果对象。
		and Duel.IsExistingTarget(s.filter1,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 向操作玩家显示“请选择要破坏的卡”的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让操作玩家从场上选择1张满足条件的表侧魔法·陷阱卡作为效果对象，自动登记为连锁对象。
	local g=Duel.SelectTarget(tp,s.filter1,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	g:AddCard(e:GetHandler())
	-- 设置连锁处理信息：即将破坏所选择的卡和此卡自身，合计2张。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,0,0)
end
-- 破坏效果处理：取出连锁对象，若对象仍与连锁相关，则把它和此卡一同以效果原因破坏。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的那一张对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		-- 将对象卡和此卡组成一组，以效果原因（REASON_EFFECT）破坏。
		Duel.Destroy(Group.FromCards(tc,e:GetHandler()),REASON_EFFECT)
	end
end
-- 除外效果条件：此卡是从额外卡组以仪式召唤方式特殊召唤成功。
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonLocation(LOCATION_EXTRA)
		and e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
-- 除外筛选条件：怪兽位于主要怪兽区（序列号小于5，即非额外怪兽区）且可以被除外。
function s.rmfilter(c)
	return c:GetSequence()<5 and c:IsAbleToRemove()
end
-- 除外效果的发动判定与操作信息设置：若存在满足条件的怪兽，则获取这些怪兽的组，并设置除外操作信息，数量为怪兽数量。
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在至少1只位于非额外怪兽区且可被除外的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 获取场上所有位于非额外怪兽区且可被除外的怪兽，组成组g。
	local g=Duel.GetMatchingGroup(s.rmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置连锁处理信息：将把组g中所有怪兽除外（数量为其计数），不指定持有者与位置。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
end
-- 除外效果处理：重新获取当前场上满足条件的怪兽，若存在则全部表侧表示除外。
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时再次获取当前场上满足除外条件的怪兽组（处理时重新确认）。
	local g=Duel.GetMatchingGroup(s.rmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		-- 将组g中的全部怪兽以表侧表示除外，原因为效果（REASON_EFFECT）。
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
-- 判定此卡是否存在于额外怪兽区：场上序列号大于4（5、6号位）。
function s.econ(e)
	return e:GetHandler():GetSequence()>4
end
-- 免疫过滤条件：只免疫其他玩家的怪兽效果（效果来源卡的所有者与此卡所有者不同）。
function s.efilter(e,te)
	return te:IsActiveType(TYPE_MONSTER) and te:GetOwner()~=e:GetOwner()
end
-- 特召筛选条件：怪兽满足可特殊召唤的状态（IsFaceupEx），种族为恶魔族，且能被效果特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsFaceupEx() and c:IsRace(RACE_FIEND)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ③效果发动时点判定：己方主要怪兽区有空位，且手卡·卡组·墓地·除外状态存在至少1只可特召的恶魔族怪兽。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认己方主要怪兽区是否有空位，无空位则不能发动。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认手卡·卡组·墓地·除外状态中是否存在至少1只满足特召条件的恶魔族怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 设置连锁处理信息：将进行一次特殊召唤，来源范围为手卡、卡组、墓地、除外状态，数量为1，处理玩家为tp。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED)
end
-- 特召效果处理：检查空位；显示选择提示；从手卡·卡组·墓地·除外状态选择1只恶魔族怪兽（以aux.NecroValleyFilter排除王家长眠之谷影响后），表侧表示特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果处理时己方主要怪兽区已无空位，则终止效果处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向操作玩家显示“请选择要特殊召唤的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让操作玩家从自己的手卡·卡组·墓地·除外状态选择1只满足条件的恶魔族怪兽作为特召对象；筛选时使用aux.NecroValleyFilter，避免王家长眠之谷禁止墓地特殊召唤。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	if #g>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到己方场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
