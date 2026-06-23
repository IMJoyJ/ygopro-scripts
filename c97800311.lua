--聖神蛇アポピス
-- 效果：
-- 有「王家的神殿」的卡名记述的怪兽×2
-- 这张卡用融合召唤以及以下方法才能特殊召唤。
-- ●把自己场上2只「阿匹卜」怪兽解放的场合可以从额外卡组特殊召唤。
-- ①：1回合1次，以自己墓地最多3张「阿匹卜」陷阱卡为对象才能发动（同名卡最多1张）。那些卡在自己场上盖放。
-- ②：1回合1次，陷阱卡发动的场合，以对方场上1张卡为对象才能发动。那张卡破坏。
local s,id,o=GetID()
-- 初始化卡片效果，注册融合素材、召唤限制、特殊召唤规则以及两个起动/诱发效果。
function s.initial_effect(c)
	-- 注册该卡记述了卡名「王家的神殿」（卡号29762407）。
	aux.AddCodeList(c,29762407)
	-- 注册融合召唤素材：2只满足s.ffilter过滤条件的怪兽。
	aux.AddFusionProcFunRep(c,s.ffilter,2,true)
	c:EnableReviveLimit()
	-- 这张卡用融合召唤以及以下方法才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 限制该卡只能通过融合召唤（或后续定义的特殊召唤规则）进行特殊召唤。
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
	-- ●把自己场上2只「阿匹卜」怪兽解放的场合可以从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetCondition(s.hspcon)
	e2:SetTarget(s.hsptg)
	e2:SetOperation(s.hspop)
	c:RegisterEffect(e2)
	-- ①：1回合1次，以自己墓地最多3张「阿匹卜」陷阱卡为对象才能发动（同名卡最多1张）。那些卡在自己场上盖放。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))  --"盖放"
	e3:SetCategory(CATEGORY_SSET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1)
	e3:SetTarget(s.settg)
	e3:SetOperation(s.setop)
	c:RegisterEffect(e3)
	-- ②：1回合1次，陷阱卡发动的场合，以对方场上1张卡为对象才能发动。那张卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))  --"破坏"
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(s.descon)
	e4:SetTarget(s.destg)
	e4:SetOperation(s.desop)
	c:RegisterEffect(e4)
end
-- 融合素材过滤条件：卡片效果文本中记述有「王家的神殿」卡名的怪兽。
function s.ffilter(c)
	-- 检查卡片是否记述了「王家的神殿」的卡名。
	return aux.IsCodeListed(c,29762407)
end
-- 特殊召唤规则的解放怪兽过滤条件：自己场上的「阿匹卜」怪兽，且可以作为特殊召唤的素材被解放。
function s.hspfilter(c,tp,sc)
	return c:IsFusionSetCard(0x1c8) and c:IsControler(tp) and c:IsReleasable(REASON_SPSUMMON)
		and c:IsCanBeFusionMaterial(sc,SUMMON_TYPE_SPECIAL)
end
-- 检查将选定的怪兽解放后，额外卡组怪兽特殊召唤的可用区域是否足够。
function s.hspchk(g,tp,sc)
	-- 检查在解放怪兽组g后，从额外卡组特殊召唤该卡所需的怪兽区域是否大于0。
	return Duel.GetLocationCountFromEx(tp,tp,g,sc)>0
end
-- 特殊召唤规则的条件：自己场上存在2只满足条件的「阿匹卜」怪兽。
function s.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取自己场上所有满足特殊召唤解放条件的「阿匹卜」怪兽。
	local rg=Duel.GetMatchingGroup(s.hspfilter,tp,LOCATION_MZONE,0,nil,tp,e:GetHandler())
	return rg:CheckSubGroup(s.hspchk,2,2,tp,e:GetHandler())
end
-- 特殊召唤规则的目标选择：选择2只自己场上的「阿匹卜」怪兽，并将其保存在效果标签对象中。
function s.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己场上可用于特殊召唤解放的「阿匹卜」怪兽。
	local rg=Duel.GetMatchingGroup(s.hspfilter,tp,LOCATION_MZONE,0,nil,tp,e:GetHandler())
	-- 提示玩家选择要解放的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local sg=rg:SelectSubGroup(tp,s.hspchk,true,2,2,tp,e:GetHandler())
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤规则的执行：解放选定的怪兽，并释放保存的卡片组。
function s.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选定的怪兽因特殊召唤原因解放。
	Duel.Release(g,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 效果①的墓地目标过滤条件：自己墓地的「阿匹卜」陷阱卡，且可以在场上盖放并能成为效果对象。
function s.setfilter(c)
	return c:IsSetCard(0x1c8) and c:IsType(TYPE_TRAP) and c:IsSSetable() and c:IsCanBeEffectTarget()
end
-- 效果①的发动准备：选择自己墓地最多3张不同名的「阿匹卜」陷阱卡作为对象，并设置离开墓地的操作信息。
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取自己墓地所有满足条件的「阿匹卜」陷阱卡。
	local g=Duel.GetMatchingGroup(s.setfilter,tp,LOCATION_GRAVE,0,nil)
	-- 计算自己魔法与陷阱区域的空位数与3的较小值，作为最大可盖放数量。
	local ft=math.min((Duel.GetLocationCount(tp,LOCATION_SZONE)),3)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.setfilter(chkc) end
	if chk==0 then return ft>0 and g:GetCount()>0 end
	-- 提示玩家选择要盖放的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 玩家选择1到ft张卡名互不相同的卡片。
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,1,ft)
	-- 将选定的卡片注册为当前效果的对象。
	Duel.SetTargetCard(sg)
	-- 设置操作信息：包含将选定的卡片从墓地移开。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,sg,1,0,0)
end
-- 效果①的效果处理：将仍是对象且不受王家长眠之谷影响的卡片在自己场上盖放。
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetsRelateToChain()
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if #tg==0 or ft<=0 then return end
	if #tg>ft then
		-- 提示玩家选择要盖放的卡片（当对象数量超过可用格子时）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
		tg=tg:Select(tp,ft,ft,nil)
	end
	-- 将符合条件的卡片在自己场上盖放。
	Duel.SSet(tp,tg)
end
-- 效果②的发动条件：陷阱卡发动时。
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_TRAP)
end
-- 效果②的发动准备：以对方场上1张卡为对象，并设置破坏的操作信息。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 检查对方场上是否存在可以作为对象的卡片。
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1张卡作为效果的对象。
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息：破坏选定的1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果②的效果处理：将作为对象的卡片破坏。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为对象的卡片。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		-- 将作为对象的卡片因效果原因破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
