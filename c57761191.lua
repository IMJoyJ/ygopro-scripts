--真竜機兵ダースメタトロン
-- 效果：
-- 这张卡通常召唤的场合，必须把3只怪兽解放作召唤，可以作为怪兽的代替而把自己场上的永续魔法·永续陷阱卡解放。
-- ①：这张卡不受原本种类（怪兽·魔法·陷阱）和为这张卡的上级召唤而解放的卡相同的卡的效果影响。
-- ②：上级召唤的这张卡被对方破坏的场合才能发动。地·水·炎·风属性的其中1只融合·同调·超量怪兽从额外卡组特殊召唤。
function c57761191.initial_effect(c)
	-- 这张卡通常召唤的场合，必须把3只怪兽解放作召唤，可以作为怪兽的代替而把自己场上的永续魔法·永续陷阱卡解放。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_LIMIT_SUMMON_PROC)
	e1:SetCondition(c57761191.ttcon)
	e1:SetOperation(c57761191.ttop)
	e1:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e1)
	-- 这张卡通常召唤的场合，必须把3只怪兽解放作召唤，可以作为怪兽的代替而把自己场上的永续魔法·永续陷阱卡解放。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_LIMIT_SET_PROC)
	e2:SetCondition(c57761191.setcon)
	c:RegisterEffect(e2)
	-- ①：这张卡不受原本种类（怪兽·魔法·陷阱）和为这张卡的上级召唤而解放的卡相同的卡的效果影响。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_MATERIAL_CHECK)
	e3:SetValue(c57761191.valcheck)
	c:RegisterEffect(e3)
	-- ①：这张卡不受原本种类（怪兽·魔法·陷阱）和为这张卡的上级召唤而解放的卡相同的卡的效果影响。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetCondition(c57761191.regcon)
	e4:SetOperation(c57761191.regop)
	e4:SetLabelObject(e3)
	c:RegisterEffect(e4)
	-- ②：上级召唤的这张卡被对方破坏的场合才能发动。地·水·炎·风属性的其中1只融合·同调·超量怪兽从额外卡组特殊召唤。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(57761191,1))  --"融合·同调·超量怪兽从额外卡组特殊召唤"
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCode(EVENT_DESTROYED)
	e5:SetCondition(c57761191.spcon)
	e5:SetTarget(c57761191.sptg)
	e5:SetOperation(c57761191.spop)
	c:RegisterEffect(e5)
end
-- 过滤自己场上可以作为上级召唤解放的永续魔法·永续陷阱卡
function c57761191.otfilter(c)
	return c:IsType(TYPE_CONTINUOUS) and c:IsReleasable(REASON_SUMMON)
end
-- 检查是否满足上级召唤所需的解放卡片数量和位置要求
function c57761191.ttcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取自己场上可以解放的永续魔法·永续陷阱卡组
	local mg=Duel.GetMatchingGroup(c57761191.otfilter,tp,LOCATION_SZONE,0,nil)
	-- 检查在怪兽区域有空位时，是否能解放3张永续魔陷进行召唤
	return minc<=3 and (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and mg:GetCount()>=3
		-- 检查是否能解放1只怪兽和2张永续魔陷进行召唤
		or Duel.CheckTribute(c,1) and mg:GetCount()>=2
		-- 检查是否能解放2只怪兽和1张永续魔陷进行召唤
		or Duel.CheckTribute(c,2) and mg:GetCount()>=1
		-- 检查是否能解放3只怪兽进行召唤
		or Duel.CheckTribute(c,3))
end
-- 执行上级召唤时的解放卡片选择与处理
function c57761191.ttop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 获取自己场上可以解放的永续魔法·永续陷阱卡组
	local mg=Duel.GetMatchingGroup(c57761191.otfilter,tp,LOCATION_SZONE,0,nil)
	-- 获取自己场上可用的怪兽区域空格数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local g=Group.CreateGroup()
	local ct=3
	-- 循环判断是否还有可解放的永续魔陷，且剩余所需的解放卡片数量可以通过怪兽或空位来满足
	while mg:GetCount()>0 and (ct>2 and Duel.CheckTribute(c,ct-2) or ct>1 and Duel.CheckTribute(c,ct-1) or ct>0 and ft>0)
		-- 若无法仅用怪兽解放，或玩家主动选择用魔陷代替，则进入魔陷解放选择流程
		and (not Duel.CheckTribute(c,ct) or Duel.SelectYesNo(tp,aux.Stringid(57761191,0))) do  --"是否选择魔法·陷阱卡解放？"
		-- 提示玩家选择要解放的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
		local g1=mg:Select(tp,1,1,nil)
		g:Merge(g1)
		mg:Sub(g1)
		ct=ct-1
	end
	if g:GetCount()<3 then
		-- 让玩家选择剩余所需数量的怪兽作为祭品
		local g2=Duel.SelectTribute(tp,c,3-g:GetCount(),3-g:GetCount())
		g:Merge(g2)
	end
	c:SetMaterial(g)
	-- 解放所有选中的怪兽和魔陷卡片
	Duel.Release(g,REASON_SUMMON+REASON_MATERIAL)
end
-- 限制这张卡不能里侧表示放置
function c57761191.setcon(e,c,minc)
	if not c then return true end
	return false
end
-- 检查并记录为上级召唤而解放的卡片的原本卡片种类（怪兽·魔法·陷阱）
function c57761191.valcheck(e,c)
	local g=c:GetMaterial()
	local typ=0
	local tc=g:GetFirst()
	while tc do
		typ=bit.bor(typ,bit.band(tc:GetOriginalType(),0x7))
		tc=g:GetNext()
	end
	e:SetLabel(typ)
end
-- 检查这张卡是否成功进行上级召唤
function c57761191.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 根据解放卡片的种类，赋予这张卡对应的不受效果影响的抗性，并添加提示信息
function c57761191.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local typ=e:GetLabelObject():GetLabel()
	-- ①：这张卡不受原本种类（怪兽·魔法·陷阱）和为这张卡的上级召唤而解放的卡相同的卡的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c57761191.efilter)
	e1:SetLabel(typ)
	c:RegisterEffect(e1)
	if bit.band(typ,TYPE_MONSTER)~=0 then
		c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(57761191,2))  --"解放怪兽卡上级召唤"
	end
	if bit.band(typ,TYPE_SPELL)~=0 then
		c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(57761191,3))  --"解放魔法卡上级召唤"
	end
	if bit.band(typ,TYPE_TRAP)~=0 then
		c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(57761191,4))  --"解放陷阱卡上级召唤"
	end
end
-- 过滤使这张卡不受与解放卡原本种类相同的对方卡片效果影响
function c57761191.efilter(e,te)
	return te:GetHandler():GetOriginalType()&e:GetLabel()~=0 and te:GetOwner()~=e:GetOwner()
end
-- 检查是否是上级召唤的这张卡被对方破坏
function c57761191.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 过滤额外卡组中地·水·炎·风属性的融合·同调·超量怪兽
function c57761191.spfilter(c,e,tp)
	return c:IsAttribute(0xf) and c:IsType(0x802040) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查额外卡组怪兽特殊召唤所需的可用怪兽区域空格数是否大于0
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 检查额外卡组是否存在可特殊召唤的怪兽，并设置特殊召唤的操作信息
function c57761191.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查额外卡组是否存在至少1只满足条件的地·水·炎·风属性融合·同调·超量怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c57761191.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置在连锁处理时将从额外卡组特殊召唤1只怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 从额外卡组选择1只满足条件的怪兽特殊召唤
function c57761191.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从额外卡组选择1只满足条件的地·水·炎·风属性融合·同调·超量怪兽
	local g=Duel.SelectMatchingCard(tp,c57761191.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
