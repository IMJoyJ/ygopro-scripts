--DDオルトロス
-- 效果：
-- ←3 【灵摆】 3→
-- ①：1回合1次，以自己场上的其他的1张「DD」卡或「契约书」卡和场上1张魔法·陷阱卡为对象才能发动。那些卡破坏。
-- 【怪兽效果】
-- ①：自己因战斗·效果受到伤害时才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡特殊召唤时适用。这个回合，自己不是恶魔族怪兽不能特殊召唤。
function c72181263.initial_effect(c)
	-- 注册灵摆怪兽的灵摆属性（灵摆召唤、灵摆卡的发动）
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，以自己场上的其他的1张「DD」卡或「契约书」卡和场上1张魔法·陷阱卡为对象才能发动。那些卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(72181263,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c72181263.destg)
	e1:SetOperation(c72181263.desop)
	c:RegisterEffect(e1)
	-- ①：自己因战斗·效果受到伤害时才能发动。这张卡从手卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(72181263,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_HAND)
	e2:SetCode(EVENT_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCondition(c72181263.spcon)
	e2:SetTarget(c72181263.sptg)
	e2:SetOperation(c72181263.spop)
	c:RegisterEffect(e2)
	-- ②：这张卡特殊召唤时适用。这个回合，自己不是恶魔族怪兽不能特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetOperation(c72181263.regop)
	c:RegisterEffect(e3)
end
-- 过滤场上的魔法·陷阱卡，且必须存在另一张可选择的自己场上的「DD」卡或「契约书」卡
function c72181263.desfilter1(c,tp,ec,g)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
		and g:IsExists(c72181263.desfilter2,1,c,tp,ec)
end
-- 过滤自己场上表侧表示的、且不是这卡自身的「DD」卡或「契约书」卡
function c72181263.desfilter2(c,tp,ec)
	return c~=ec and c:IsFaceup() and c:IsControler(tp) and c:IsSetCard(0xaf,0xae)
end
-- 检查选取的卡片组中是否包含至少一张满足条件的魔法·陷阱卡
function c72181263.gcheck(g,tp,ec)
	return g:IsExists(c72181263.desfilter1,1,nil,tp,ec,g)
end
-- 灵摆效果的对象选择与检测函数：选择自己场上1张其他的「DD」卡或「契约书」卡和场上1张魔法·陷阱卡作为破坏对象
function c72181263.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local c=e:GetHandler()
	-- 获取场上所有可以作为效果对象的卡片
	local g=Duel.GetMatchingGroup(Card.IsCanBeEffectTarget,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,e)
	if chk==0 then return g:CheckSubGroup(c72181263.gcheck,2,2,tp,c) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	local tg=g:SelectSubGroup(tp,c72181263.gcheck,false,2,2,tp,c)
	-- 将选取的卡片注册为效果处理的对象
	Duel.SetTargetCard(tg)
	-- 设置连锁操作信息，表示该效果的处理为破坏这2张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tg,2,0,0)
end
-- 灵摆效果的执行函数：破坏作为对象的卡
function c72181263.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍与该效果相关的对象卡片
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 破坏作为对象的卡片
		Duel.Destroy(g,REASON_EFFECT)
	end
end
-- 怪兽效果①的发动条件：自己受到伤害
function c72181263.spcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp
end
-- 怪兽效果①的对象选择与检测函数：检测自身是否能特殊召唤
function c72181263.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息，表示该效果的处理为特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 怪兽效果①的执行函数：将自身特殊召唤
function c72181263.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将自身以表侧表示特殊召唤
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 怪兽效果②的执行函数：在特殊召唤成功时，注册“不能特殊召唤恶魔族以外怪兽”的限制
function c72181263.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合，自己不是恶魔族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c72181263.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将限制效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 限制条件：不能特殊召唤恶魔族以外的怪兽
function c72181263.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsRace(RACE_FIEND)
end
