--黒魔導の執行官
-- 效果：
-- 这张卡不能通常召唤。把自己场上存在的1只「黑魔术师」解放的场合才能特殊召唤。只要这张卡在场上表侧表示存在，每次自己或者对方把通常魔法卡发动，给与对方基本分1000分伤害。
function c29436665.initial_effect(c)
	-- 将本卡效果中提到的『黑魔术师』的卡号(46986414)登记到代码列表，使本卡被视为记载了该卡名。
	aux.AddCodeList(c,46986414)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 把自己场上存在的1只「黑魔术师」解放的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c29436665.spcon)
	e2:SetTarget(c29436665.sptg)
	e2:SetOperation(c29436665.spop)
	c:RegisterEffect(e2)
	-- 只要这张卡在场上表侧表示存在，每次自己或者对方把通常魔法卡发动，
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	-- 设置连锁发生时的登记函数：记录本次连锁，用于判断该魔法卡发动时此卡在场上存在。
	e3:SetOperation(aux.chainreg)
	c:RegisterEffect(e3)
	-- 给与对方基本分1000分伤害。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(29436665,0))
	e4:SetCategory(CATEGORY_DAMAGE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_CHAIN_SOLVED)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(c29436665.dmgcon)
	e4:SetOperation(c29436665.dmgop)
	c:RegisterEffect(e4)
end
-- 定义解放素材的过滤条件：卡名必须是『黑魔术师』，解放后自己场上仍有可用怪兽区，且该素材可被解放（控制者为特殊召唤玩家或表侧表示）。
function c29436665.rfilter(c,tp)
	return c:IsCode(46986414)
		-- 补充过滤：该卡被解放后tp场上仍有空余怪兽区，并且该卡满足可解放条件（控制者为自己或表侧表示）。
		and Duel.GetMZoneCount(tp,c)>0 and (c:IsControler(tp) or c:IsFaceup())
end
-- 特殊召唤条件检测：若c为空则返回true；否则检查tp是否存在至少1只符合rfilter的可解放『黑魔术师』。
function c29436665.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查tp是否存在至少1张满足rfilter条件的可解放卡，作为本次特殊召唤的解放素材。
	return Duel.CheckReleaseGroupEx(tp,c29436665.rfilter,1,REASON_SPSUMMON,false,nil,tp)
end
-- 特殊召唤目标选择处理：从可解放的『黑魔术师』中让玩家选择1张，保存到e的LabelObject；选择成功则允许继续特殊召唤，否则失败。
function c29436665.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取tp当前可解放的卡组，并用rfilter过滤出符合条件的『黑魔术师』作为候选素材。
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c29436665.rfilter,nil,tp)
	-- 向tp玩家显示解放素材选择提示，提示内容为“请选择要解放的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤操作函数：取出保存在e中的解放素材并解放，完成特殊召唤手续的代价处理。
function c29436665.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的『黑魔术师』解放，作为本次特殊召唤的代价（REASON_SPSUMMON）。
	Duel.Release(g,REASON_SPSUMMON)
end
-- 伤害触发条件：当前连锁解决时的发动者是魔法卡且为魔法卡的发动动作，并且本卡在场上时已登记过该连锁（FLAG_ID_CHAINING）。
function c29436665.dmgcon(e,tp,eg,ep,ev,re,r,rp)
	return re:GetActiveType()==TYPE_SPELL and re:IsHasType(EFFECT_TYPE_ACTIVATE) and e:GetHandler():GetFlagEffect(FLAG_ID_CHAINING)>0
end
-- 伤害效果处理函数：对对方玩家造成1000点伤害。
function c29436665.dmgop(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果原因（REASON_EFFECT）给予对方玩家(1-tp)1000点基本分伤害。
	Duel.Damage(1-tp,1000,REASON_EFFECT)
end
