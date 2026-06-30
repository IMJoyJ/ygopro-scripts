--聖神蛇アポピス
-- 效果：
-- 有「王家的神殿」的卡名记述的怪兽×2
-- 这张卡用融合召唤以及以下方法才能特殊召唤。
-- ●把自己场上2只「阿匹卜」怪兽解放的场合可以从额外卡组特殊召唤。
-- ①：1回合1次，以自己墓地最多3张「阿匹卜」陷阱卡为对象才能发动（同名卡最多1张）。那些卡在自己场上盖放。
-- ②：1回合1次，陷阱卡发动的场合，以对方场上1张卡为对象才能发动。那张卡破坏。
local s,id,o=GetID()
-- 初始化效果注册，包含融合召唤素材设定、召唤条件设定、特殊特召规则设定以及①效果和②效果的注册
function s.initial_effect(c)
	-- 在卡片中记录关联了「王家的神殿」的信息
	aux.AddCodeList(c,29762407)
	-- 设置融合素材：用2个满足特定条件的怪兽为融合素材
	aux.AddFusionProcFunRep(c,s.ffilter,2,true)
	c:EnableReviveLimit()
	-- 这张卡用融合召唤以及以下方法才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤限制条件为：不能用融合召唤以外的方式特殊召唤
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
-- 融合素材过滤条件：有「王家的神殿」的卡名记述的怪兽
function s.ffilter(c)
	-- 检查卡片效果文本上是否记载着「王家的神殿」
	return aux.IsCodeListed(c,29762407)
end
-- 额外卡组特殊召唤规则的素材过滤条件：自己场上可以解放的「阿匹卜」怪兽
function s.hspfilter(c,tp,sc)
	return c:IsFusionSetCard(0x1c8) and c:IsControler(tp) and c:IsReleasable(REASON_SPSUMMON)
		and c:IsCanBeFusionMaterial(sc,SUMMON_TYPE_SPECIAL)
end
-- 额外特殊召唤规则的区域检测条件
function s.hspchk(g,tp,sc)
	-- 检查将指定卡片解放后，额外卡组怪兽是否有空闲的出场位置
	return Duel.GetLocationCountFromEx(tp,tp,g,sc)>0
end
-- 额外特殊召唤规则的发动条件：自己场上存在符合解放条件的2只「阿匹卜」怪兽
function s.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取自己场上所有符合特殊召唤素材要求的「阿匹卜」怪兽
	local rg=Duel.GetMatchingGroup(s.hspfilter,tp,LOCATION_MZONE,0,nil,tp,e:GetHandler())
	return rg:CheckSubGroup(s.hspchk,2,2,tp,e:GetHandler())
end
-- 额外特殊召唤规则素材的选择：让玩家选择2只「阿匹卜」怪兽作为解放素材
function s.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 再次获取自己场上所有符合特殊召唤素材要求的「阿匹卜」怪兽
	local rg=Duel.GetMatchingGroup(s.hspfilter,tp,LOCATION_MZONE,0,nil,tp,e:GetHandler())
	-- 提示玩家选择要解放的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local sg=rg:SelectSubGroup(tp,s.hspchk,true,2,2,tp,e:GetHandler())
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 额外特殊召唤规则的效果处理：将选择的素材怪兽解放
function s.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将怪兽作为特殊召唤的代理解放
	Duel.Release(g,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 过滤条件：墓地中可以盖放的「阿匹卜」陷阱卡
function s.setfilter(c)
	return c:IsSetCard(0x1c8) and c:IsType(TYPE_TRAP) and c:IsSSetable() and c:IsCanBeEffectTarget()
end
-- ①效果（盖放墓地「阿匹卜」陷阱卡）的发动准备与目标选择
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取自己墓地中所有符合盖放条件的「阿匹卜」陷阱卡
	local g=Duel.GetMatchingGroup(s.setfilter,tp,LOCATION_GRAVE,0,nil)
	-- 获取自己魔陷区可用空格数与3的较小值，以限制可以盖放的最大数量
	local ft=math.min((Duel.GetLocationCount(tp,LOCATION_SZONE)),3)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.setfilter(chkc) end
	if chk==0 then return ft>0 and g:GetCount()>0 end
	-- 提示玩家选择要盖放的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 让玩家选择1到ft张互不同名的「阿匹卜」陷阱卡作为效果对象
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,1,ft)
	-- 将选择的卡片设置为连锁效果的对象
	Duel.SetTargetCard(sg)
	-- 设置效果处理的信息为卡片离开墓地
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,sg,1,0,0)
end
-- ①效果的处理：将选择的墓地卡片在自己场上盖放
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍与效果关联且未受王家长眠之谷影响的卡片
	local tg=Duel.GetTargetsRelateToChain():Filter(aux.NecroValleyFilter(),nil)
	-- 获取自己场上可用的魔陷区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if #tg==0 or ft<=0 then return end
	if #tg>ft then
		-- 提示玩家选择要盖放的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
		tg=tg:Select(tp,ft,ft,nil)
	end
	-- 将卡片在自己场上盖放
	Duel.SSet(tp,tg)
end
-- ②效果（陷阱卡发动时破坏对方卡）的发动条件：当陷阱卡的效果或卡片发动时
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_TRAP)
end
-- ②效果的发动准备与目标选择
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 检查对方场上是否存在至少1张卡可以成为效果对象
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择对方场上的1张卡作为效果对象
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理的分类为破坏，目标为选择的对象卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ②效果的处理：将选择的对方场上的那张对象卡破坏
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取要破坏的对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		-- 将目标卡片因效果破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
