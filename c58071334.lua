--蛇眼の原罪龍
-- 效果：
-- 「蛇眼」怪兽＋幻想魔族怪兽
-- 这张卡用融合召唤以及以下方法才能特殊召唤。
-- ●把自己的魔法与陷阱区域2张表侧表示的怪兽卡送去墓地的场合可以从额外卡组特殊召唤。这个卡名的效果1回合只能使用1次。
-- ①：这张卡特殊召唤的场合，以场上1只表侧表示怪兽为对象才能发动。那只怪兽当作永续魔法卡使用在原本持有者的魔法与陷阱区域表侧表示放置。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含融合素材、特殊召唤限制、自身特召规则以及特召成功时的诱发效果。
function s.initial_effect(c)
	-- 设置融合素材为「蛇眼」怪兽和幻想魔族怪兽各1只。
	aux.AddFusionProcFun2(c,s.mfilter1,s.mfilter2,true)
	c:EnableReviveLimit()
	-- 这张卡用融合召唤以及以下方法才能特殊召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 限制该卡不能用融合召唤（以及自身特召规则）以外的方式特殊召唤。
	e0:SetValue(aux.fuslimit)
	c:RegisterEffect(e0)
	-- ●把自己的魔法与陷阱区域2张表侧表示的怪兽卡送去墓地的场合可以从额外卡组特殊召唤。这个卡名的效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(s.hspcon)
	e1:SetTarget(s.hsptg)
	e1:SetOperation(s.hspop)
	c:RegisterEffect(e1)
	-- ①：这张卡特殊召唤的场合，以场上1只表侧表示怪兽为对象才能发动。那只怪兽当作永续魔法卡使用在原本持有者的魔法与陷阱区域表侧表示放置。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"表侧表示放置"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.mvtg)
	e2:SetOperation(s.mvop)
	c:RegisterEffect(e2)
end
-- 过滤条件：属于「蛇眼」字段的怪兽。
function s.mfilter1(c)
	return c:IsFusionSetCard(0x19c)
end
-- 过滤条件：幻想魔族怪兽。
function s.mfilter2(c)
	return c:IsRace(RACE_ILLUSION)
end
-- 自身特召规则的素材过滤：原本卡片类型为怪兽、在魔陷区表侧表示存在、能送去墓地且能作为该卡的融合素材。
function s.sprfilter(c,sc)
	return c:GetOriginalType()&TYPE_MONSTER~=0 and c:IsFaceup()
		and c:IsAbleToGraveAsCost() and c:IsCanBeFusionMaterial(sc,SUMMON_TYPE_SPECIAL)
end
-- 检查将选定的卡送去墓地后，是否能从额外卡组特殊召唤该卡（检查额外怪兽区域的可用空格）。
function s.sgchk(g,tp,sc)
	-- 检查在选定的卡片离场后，是否有可用的额外怪兽区域或其指向的区域来特殊召唤这张卡。
	return Duel.GetLocationCountFromEx(tp,tp,g,sc)>0
end
-- 自身特召规则的条件：检查自己魔陷区是否存在2张满足条件的表侧表示怪兽卡。
function s.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取自己魔陷区所有满足特召素材条件的表侧表示怪兽卡。
	local g=Duel.GetMatchingGroup(s.sprfilter,tp,LOCATION_SZONE,0,c,c)
	return g:CheckSubGroup(s.sgchk,2,2,tp,c)
end
-- 自身特召规则的准备阶段：选择自己魔陷区2张表侧表示的怪兽卡，并将其作为LabelObject保存。
function s.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local cp=c:GetControler()
	-- 获取当前玩家魔陷区所有满足特召素材条件的表侧表示怪兽卡。
	local g=Duel.GetMatchingGroup(s.sprfilter,cp,LOCATION_SZONE,0,c,c)
	-- 提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,cp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local sg=g:SelectSubGroup(cp,s.sgchk,true,2,2,cp,c)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 自身特召规则的执行阶段：将选定的素材卡送去墓地，并特殊召唤这张卡。
function s.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local sg=e:GetLabelObject()
	c:SetMaterial(sg)
	-- 将选定的2张怪兽卡作为特殊召唤的消耗送去墓地。
	Duel.SendtoGrave(sg,REASON_SPSUMMON)
end
-- 效果①的对象过滤条件：场上表侧表示的怪兽，且其原本持有者的魔陷区有空位。
function s.mvfilter(c,tp)
	local r=LOCATION_REASON_TOFIELD
	if not c:IsControler(c:GetOwner()) then
		if not c:IsAbleToChangeControler() then return false end
		r=LOCATION_REASON_CONTROL
	end
	-- 检查怪兽是否表侧表示，且其原本持有者的魔陷区是否有可用空格。
	return c:IsFaceup() and Duel.GetLocationCount(c:GetOwner(),LOCATION_SZONE,tp,r)>0
end
-- 效果①的靶向阶段：选择场上1只表侧表示怪兽作为对象。
function s.mvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.mvfilter(chkc,tp) end
	-- 检查场上是否存在可以作为效果①对象的表侧表示怪兽。
	if chk==0 then return Duel.IsExistingTarget(s.mvfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp) end
	-- 提示玩家选择表侧表示的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 玩家选择1只满足条件的表侧表示怪兽作为效果对象。
	Duel.SelectTarget(tp,s.mvfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp)
end
-- 效果①的执行阶段：将对象怪兽移动到其原本持有者的魔陷区，并使其当作永续魔法卡使用。
function s.mvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果①选定的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) and not tc:IsImmuneToEffect(e)
		-- 将对象怪兽表侧表示移动到其原本持有者的魔法与陷阱区域。
		and Duel.MoveToField(tc,tp,tc:GetOwner(),LOCATION_SZONE,POS_FACEUP,true) then
		-- 那只怪兽当作永续魔法卡使用
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
		tc:RegisterEffect(e1)
	end
end
