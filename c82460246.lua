--伍世壊＝カラリウム
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这个卡名的③的效果1回合只能使用1次。
-- ①：作为这张卡的发动时的效果处理，可以从卡组把1只「末那愚子族」怪兽或者「维萨斯-斯塔弗罗斯特」加入手卡。
-- ②：自己场上的光属性怪兽的攻击力上升自己的场上·墓地的调整数量×100。
-- ③：自己场上的表侧表示的调整被战斗·效果破坏的场合，以那1只怪兽为对象才能发动。那只怪兽特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含卡片发动时的检索效果、场上光属性怪兽攻击力上升的永续效果，以及调整被破坏时特殊召唤该怪兽的诱发效果
function s.initial_effect(c)
	-- 在卡片中记录关联卡片「维萨斯-斯塔弗罗斯特」（卡号56099748），用于支持其他卡片的检索或相关效果检测
	aux.AddCodeList(c,56099748)
	-- 这个卡名的卡在1回合只能发动1张。①：作为这张卡的发动时的效果处理，可以从卡组把1只「末那愚子族」怪兽或者「维萨斯-斯塔弗罗斯特」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：自己场上的光属性怪兽的攻击力上升自己的场上·墓地的调整数量×100。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.atktg)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
	-- 这个卡名的③的效果1回合只能使用1次。③：自己场上的表侧表示的调整被战斗·效果破坏的场合，以那1只怪兽为对象才能发动。那只怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 过滤卡组中满足「末那愚子族」怪兽或「维萨斯-斯塔弗罗斯特」且能加入手卡的卡片的过滤函数
function s.filter(c)
	local b1=c:IsSetCard(0x190) and c:IsType(TYPE_MONSTER)
	local b2=c:IsCode(56099748)
	return (b1 or b2) and c:IsAbleToHand()
end
-- 卡片发动时的效果处理函数，若卡组有符合条件的卡，玩家可以选择将其中1张加入手卡并给对方确认
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己卡组中所有满足过滤条件的卡片组
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil)
	-- 判断卡组中是否存在符合条件的卡，并询问玩家是否选择发动该检索效果
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then  --"是否从卡组把怪兽加入手卡？"
		-- 提示玩家选择要加入手牌的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的卡片因效果加入玩家手卡
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 将加入手卡的卡片向对方玩家进行确认
		Duel.ConfirmCards(1-tp,sg)
	end
end
-- 攻击力上升效果的适用对象过滤函数，仅适用于自己场上表侧表示的光属性怪兽
function s.atktg(e,c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT)
end
-- 过滤场上表侧表示或墓地中的调整怪兽的过滤函数
function s.ckfilter(c)
	return c:IsType(TYPE_TUNER) and c:IsFaceupEx()
end
-- 计算攻击力上升数值的函数，返回自己场上及墓地的调整怪兽数量乘以100的值
function s.atkval(e,c)
	-- 获取自己场上（表侧表示）和墓地中调整怪兽的总数量
	local ct=Duel.GetMatchingGroupCount(s.ckfilter,e:GetHandlerPlayer(),LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	return ct*100
end
-- 过滤被战斗或效果破坏的自己场上表侧表示的非衍生物调整怪兽的过滤函数
function s.cfilter(c,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and bit.band(c:GetPreviousTypeOnField(),TYPE_TUNER)~=0 and not c:IsType(TYPE_TOKEN)
		and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
-- 过滤可以作为效果对象且可以被特殊召唤的怪兽的过滤函数
function s.tgfilter(c,e,tp)
	return c:IsCanBeEffectTarget(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果③的发动条件判断函数，检查被破坏的卡片中是否存在满足条件的自己场上的调整怪兽
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- 效果③的发动准备与目标选择函数，用于确认怪兽区域空位、选择被破坏的调整怪兽作为对象并设置特殊召唤的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local mg=eg:Filter(s.cfilter,nil,tp):Filter(s.tgfilter,nil,e,tp)
	if chkc then return mg:IsContains(chkc) end
	-- 效果发动时的可行性检测：检查是否存在可作为对象的被破坏怪兽，且自己场上是否有可用于特殊召唤的怪兽区域空位
	if chk==0 then return #mg>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	local g=mg
	if #mg>1 then
		-- 提示玩家选择效果的对象
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
		g=mg:Select(tp,1,1,nil)
	end
	-- 将选中的怪兽注册为当前连锁的效果处理对象
	Duel.SetTargetCard(g)
	-- 设置当前连锁的操作信息，表明此效果包含将1只目标怪兽特殊召唤的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果③的效果处理函数，将作为对象的怪兽在自己场上特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	-- 将目标怪兽以表侧表示特殊召唤到发动效果的玩家场上
	Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
end
