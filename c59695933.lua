--インターセプト
-- 效果：
-- 需要1只怪兽解放的怪兽的召唤成功时才能发动。得到那1只怪兽的控制权。
function c59695933.initial_effect(c)
	-- 需要1只怪兽解放的怪兽的召唤成功时才能发动。得到那1只怪兽的控制权。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c59695933.condition)
	e1:SetTarget(c59695933.target)
	e1:SetOperation(c59695933.activate)
	c:RegisterEffect(e1)
	if not c59695933.global_check then
		c59695933.global_check=true
		-- 需要1只怪兽解放的怪兽
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD)
		ge1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE)
		ge1:SetCode(EFFECT_MATERIAL_CHECK)
		ge1:SetValue(c59695933.valcheck)
		-- 注册全局环境效果，用于检查怪兽召唤时的解放素材
		Duel.RegisterEffect(ge1,0)
	end
end
-- 检查怪兽上级召唤时是否仅将1只怪兽作为解放素材，若是则给该怪兽注册一个标识
function c59695933.valcheck(e,c)
	if c:GetMaterialCount()==1 and c:GetMaterial():GetFirst():IsType(TYPE_MONSTER) then
		c:RegisterFlagEffect(59695933,0,0,0)
	end
end
-- 判断是否为需要1只怪兽解放的上级召唤成功时，并重置该怪兽的标识
function c59695933.condition(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	local res=tc:IsSummonType(SUMMON_TYPE_ADVANCE) and tc:GetFlagEffect(59695933)~=0
	tc:ResetFlagEffect(59695933)
	return res
end
-- 过滤并选择召唤成功的怪兽作为效果对象，并声明控制权转移的操作信息
function c59695933.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return eg:GetFirst():IsCanBeEffectTarget(e) and eg:GetFirst():IsControlerCanBeChanged() end
	-- 将召唤成功的怪兽设为效果的对象
	Duel.SetTargetCard(eg)
	-- 设置操作信息为转移该怪兽的控制权
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,eg,1,0,0)
end
-- 在效果处理时，获取目标怪兽并让发动效果的玩家获得其控制权
function c59695933.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 让发动效果的玩家获得目标怪兽的控制权
		Duel.GetControl(tc,tp)
	end
end
